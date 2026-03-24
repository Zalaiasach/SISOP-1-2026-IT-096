#!/bin/bash

mkdir -p data log rekap sampah
touch data/penghuni.csv log/tagihan.log rekap/laporan_bulanan.txt sampah/history_hapus.csv

SCRIPT_PATH=$(realpath "$0")

if [[ "$1" == "--check-tagihan" ]]; then
	waktu=$(date +"%Y-%m-%d %H:%M:%S")
	awk -F, -v time="$waktu" 'tolower($5) == "menunggak"{
		printf "[%s] TAGIHAN: %s (Kamar %s) - Menunggak Rp%s\n", time, $1, $2, $3 >>"log/tagihan.log"
	}' data/penghuni.csv
	exit 0
fi

tambah_penghuni() {
	echo "=========================================="
    	echo "             TAMBAH PENGHUNI              "
    	echo "=========================================="
	read -p "Masuka Nama: " nama

	while true; do 
		read -p "Masukan Kamar: " kamar
		if grep -q  "^.*,$kamar,.*,.*,.*$" data/penghuni.csv; then
			echo "Error: Nomor kamar $kamar sudah terisi! pilih kamar yang lain (gaboleh tidur berdua cik)"
		else
			break
		fi
	done

	while true; do 
		read -p "Masukan harga sewa: " harga
		if [[ "$harga" =~ ^[0-9]+$ ]] && [ "$harga" -gt 0 ]; then
			break
		else
			echo "Error: Harga sewa nggak bisa minus (malah yang punya kos yang bayar njir)"
		fi
	done

	hari_ini=$(date +%Y-%m-%d)
	while true; do
		read -p "Masukan tanggal masuk (YYYY-MM-DD): " tanggal
		if [[ ! "$tanggal" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
			echo "Error: format penanggalan salah, gunakan format asia timur (YYYY-MM-DD)"
			continue
		fi

		if ! date -d "$tanggal" >/dev/null 2>&1; then
			echo "Error: Tanggal nggak valid"
			continue
		fi

		if [[ "$tanggal" > "$hari_ini" ]]; then
			echo "Error: Tanggal tidak boleh dari masa depan (kamu bukan doraemon)"
		else
			break
		fi
	done

	while true; do
		read -p "Masukan status awal (Aktif/Menunggak): " status_bayar
		status_lower=$(echo "$status_bayar" | tr '[:upper:]' '[:lower:]')
		if [[ "$status_lower" == "aktif" ]]; then
			status="Aktif"
			break
		elif [[ "$status_lower" == "menunggak" ]]; then
			status="Menunggak"
			break
		else
			echo "Error: Yang bener aja cik. Kalo ngga Aktif, ya Menunggak (pilih satu)"
		fi
	done

	echo "$nama,$kamar,$harga,$tanggal,$status" >> data/penghuni.csv
	echo -e "\n[✓] Penghuni $nama berhasil ditambahkan!"
    	read -p "Tekan [ENTER] untuk kembali ke menu..."
}

hapus_penghuni() {
	echo "=========================================="
    	echo "              HAPUS PENGHUNI              "
    	echo "=========================================="
    	read -p "Masukkan nama penghuni yang akan dihapus: " nama
	
	record=$(awk -F, -v n="$nama" 'tolower($1)==tolower(n) {print $0; exit}' data/penghuni.csv)

	if [[ -n "$record" ]]; then
		tanggal_hapus=$(date +%Y-%m-%d)
		echo "$record,$tanggal_hapus" >> sampah/history_hapus.csv

		awk -F, -v n="$nama" 'tolower($1)!=tolower(n)' data/penghuni.csv > data/temp.csv
		mv data/temp.csv data/penghuni.csv

		echo -e "\n[✓] Data penghuni \"$nama\" berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus dari sistem."
	else
		echo -e "\n[X] Data penghuni \"$nama\" tidak ditemukan."
	fi
	read -p "Tekan [ENTER] untuk kembali ke menu..."
}

tampilkan_daftar() {
	echo "================================================================="
    	echo "                  DAFTAR PENGHUNI KOST SLEBEW                    "
    	echo "================================================================="
	
	awk -F, '
	BEGIN {
		printf "%-3s | %-15s | %-5s | %-15s | %-10s\n", "No", "Nama", "Kamar", "Harga Sewa", "Status"
        	print "-----------------------------------------------------------------"
        	total=0; aktif=0; nunggak=0
	}
	{
		if(length($1) > 0) {
            		total++
            		if (tolower($5) == "aktif") aktif++
            		if (tolower($5) == "menunggak") nunggak++
            		printf "%-3d | %-15s | %-5s | Rp%-13s | %-10s\n", total, $1, $2, $3, $5
        	}
	}
	END {
		print "-----------------------------------------------------------------"
        	printf "Total: %d penghuni | Aktif: %d | Menunggak: %d\n", total, aktif, nunggak
        	print "-----------------------------------------------------------------"
	}' data/penghuni.csv

	read -p "Tekan [ENTER] untuk kembali ke menu..."
}

update_status() {
	echo "=========================================="
    	echo "               UPDATE STATUS              "
    	echo "=========================================="
    	read -p "Masukkan Nama Penghuni: " nama
    	read -p "Masukkan Status Baru (Aktif/Menunggak): " status_baru

	stat_lower=$(echo "$status_baru" | tr '[:upper:]' '[:lower:]')
	if [[ "$stat_lower" == "aktif" ]]; then
		stat_valid="Aktif"
	elif [[ "$stat_lower" == "menunggak" ]]; then
        	stat_valid="Menunggak"
    	else
        	echo "Error: Status tidak valid."
        	read -p "Tekan [ENTER] untuk kembali ke menu..."
        	return
	fi

	if grep -iq "^$nama," data/penghuni.csv; then
		awk -F, -v n="$nama" -v s="$stat_valid" 'BEGIN{OFS=","} tolower($1)==tolower(n) {$5=s} 1' data/penghuni.csv > data/temp.csv
		mv data/temp.csv data/penghuni.csv
		echo -e "\n[✓] Status $nama berhasil diubah menjadi: $stat_valid"
    	else
        	echo -e "\n[X] Penghuni dengan nama $nama tidak ditemukan."
    	fi
    	read -p "Tekan [ENTER] untuk kembali ke menu..."
}

cetak_laporan() {
    	echo "------------------------------------------------"
    	echo "          LAPORAN KEUANGAN KOST SLEBEW          "
    	echo "------------------------------------------------"
    
    	awk -F, '
    	BEGIN {
        	pemasukan = 0
        	tunggakan = 0
        	kamar_terisi = 0
        	daftar_nunggak = ""
    	}
    	{
        	if(length($1) > 0) {
            		kamar_terisi++
           		if (tolower($5) == "aktif") {
                		pemasukan += $3
            		} else if (tolower($5) == "menunggak") {
                		tunggakan += $3
                		daftar_nunggak = daftar_nunggak "- " $1 " (Kamar " $2 ") - Rp" $3 "\n"
            		}
        	}
    	}
    	END {
        	report_file = "rekap/laporan_bulanan.txt"
        
        	printf "Total pemasukan (Aktif) : Rp%d\n", pemasukan
        	printf "Total tunggakan         : Rp%d\n", tunggakan
        	printf "Jumlah kamar terisi     : %d\n\n", kamar_terisi
        	print "Daftar penghuni menunggak:"
        	if (length(daftar_nunggak) > 0) {
            		printf "%s", daftar_nunggak
        	} else {
            		print "  Tidak ada tunggakan."
        	}
        
        	printf "LAPORAN KEUANGAN KOST SLEBEW\n" > report_file
        	printf "--------------------------------\n" >> report_file
        	printf "Total pemasukan (Aktif) : Rp%d\n", pemasukan >> report_file
        	printf "Total tunggakan         : Rp%d\n", tunggakan >> report_file
        	printf "Jumlah kamar terisi     : %d\n\n", kamar_terisi >> report_file
        	printf "Daftar penghuni menunggak:\n" >> report_file
        	if (length(daftar_nunggak) > 0) {
             		printf "%s", daftar_nunggak >> report_file
        	} else {
             		print "  Tidak ada tunggakan." >> report_file
        	}
    	}' data/penghuni.csv
    
    	echo -e "\n[✓] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
    	read -p "Tekan [ENTER] untuk kembali ke menu..."
}

kelola_cron() {
    	while true; do
        	clear
        	echo "=========================================="
        	echo "             MENU KELOLA CRON             "
        	echo "=========================================="
        	echo "1. Lihat Cron Job Aktif"
        	echo "2. Daftarkan Cron Job Pengingat"
        	echo "3. Hapus Cron Job Pengingat"
        	echo "4. Kembali"
        	echo "=========================================="
        	read -p "Pilih [1-4]: " pilihan_cron

        	case $pilihan_cron in
            		1)
                		echo -e "\n--- Daftar Cron Job Pengingat Tagihan ---"
                		if crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH --check-tagihan"; then
                    			crontab -l | grep "$SCRIPT_PATH --check-tagihan"
                		else
                    			echo "Tidak ada cron job aktif."
                		fi
                		read -p "Tekan [ENTER] untuk kembali..."
                		;;
            		2)
                		read -p "Masukkan Jam (0-23): " jam
                		read -p "Masukkan Menit (0-59): " menit
                
                		(crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH --check-tagihan") | crontab -
                
                		(crontab -l 2>/dev/null; echo "$menit $jam * * * $SCRIPT_PATH --check-tagihan") | crontab -
                		echo -e "\n[✓] Cron job berhasil ditambahkan untuk jam $jam:$menit."
                		read -p "Tekan [ENTER] untuk kembali..."
                		;;
            		3)
                		(crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH --check-tagihan") | crontab -
                		echo -e "\n[✓] Cron job pengingat tagihan berhasil dihapus."
                		read -p "Tekan [ENTER] untuk kembali..."
                		;;
            		4)
                		break
                		;;
            		*)
                		echo "Pilihan tidak valid."
                		sleep 1
                		;;
        	esac
    	done
}

while true; do
	clear
    	echo " _  __        _     ____  _      _"
    	echo "| |/ /___ ___| |_  / ___|| | ___| |__   _____      __"
    	echo "| ' // _ / __| __| \___ \| |/ _ | '_ \ / _ \ \ /\ / /"
    	echo "| . \ (_) \__ | |_   ___) | |  __| |_) |  __/\ V  V /"
    	echo "|_|\_\___/|___/\__| |____/|_|\___|_.__/ \___| \_/\_/"
    	echo "                                                 "
    	echo "      SISTEM MANAJEMEN KOST SLEBEW AMBATUKAM     "
    	echo "-------------------------------------------------"
    	echo " ID | OPTION                                     "
    	echo "-------------------------------------------------"
    	echo "  1 | Tambah Penghuni Baru"
    	echo "  2 | Hapus Penghuni"
    	echo "  3 | Tampilkan Daftar Penghuni"
    	echo "  4 | Update Status Penghuni"
    	echo "  5 | Cetak Laporan Keuangan"
    	echo "  6 | Kelola Cron (Pengingat Tagihan)"
    	echo "  7 | Exit Program"
    	echo "-------------------------------------------------"
    	read -p "Enter option [1-7]: " menu_utama

    	case $menu_utama in
        	1) tambah_penghuni ;;
        	2) hapus_penghuni ;;
        	3) tampilkan_daftar ;;
        	4) update_status ;;
        	5) cetak_laporan ;;
        	6) kelola_cron ;;
        	7) 
            		echo "Terima kasih telah menggunakan sistem Manajemen Kost Slebew!"
            		exit 0 
            	;;
        	*) 
            		echo "Pilihan tidak valid. Silakan pilih 1-7."
            		sleep 1 
            	;;
    	esac
done
