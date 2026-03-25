# SISOP-1-2026-IT-096
# Praktikum Sistem Operasi Modul 1
by Afriezal Suryapraba Laiasach | 5027251096

### Tree file tugas

![file tree](assets/tree.png)

## Soal 1
Di soal ini, kita diberi sebuah file csv bernama passenger.csv dalam bentuk link untuk didownload.  
kita bisa mendownload file ini menggunakan:  
`wget -O passenger.csv "(link file csv)"`  

Dari file csv tersebut, kita diperintahkan untuk:   
a. Menghitung jumlah semua penumpang kereta  
b. Jumlah gerbong kereta  
c. Siapa penumpang tertua dan berapa umurnya  
d. Rata-rata usia penumpang  
e. Jumlah penumpang bussiness class  

setelah didownload, kita dapat memulai mengerjakan scriptnya. Sesuai dengan soal, script nya akan saya namakan KANJ.sh. Untuk pengerjaan penulisan script, saya menggunakan Vim sehingga untuk membuat file .sh dapat dilakukan dengan:  
`vim KANJ.sh`  

### Script KANJ.sh
Di file csv, setiap kolom dilambangkan oleh '$'. Jadi sesuai dengan isi file passenger.csv, urutan kolom sebagai berikut:  
$1 = Nama penumpang  
$2 = Usia penumpang  
$3 = Kelas  
$4 = Gerbong penumbang  

kita akan menggunakan `awk` , sebuah bahasa pemrograman khusus untuk pemrosesan teks, ekstraksi data, dan pembuatan laporan terstruktur pada sistem Unix/Linux.  
#### BEGIN

![soal1BEGIN](assets/soal1Begin.png)

Pada soal kita diberitahu bahwa untuk meng-output file, kita diarahkan untuk menggunakan:  
`awk -f KANJ.sh passenger.csv a/b/c/d/e`  

Karena hal itu kita menggunakan *shebang* `#!/usr/bin/awk -f` .  
Hal ini digunakan untuk memberitahu sistem operasi bahwa file ini harus dijalankan menggunakan program awk.   

Pada blok pertama seperti yang di gambar adalah blok BEGIN. Blok ini menjalankan perintah sebanyak satu  kali sebelum file dibaca oleh awk.   

`FS= ","` FS (Field Seperator) menentukan pemisah antar kolom berupa tanda koma (,).  
`RS="\r\n"` RS(Record Seperator) menentukan bahwa setiap baris yang diakhiri \r\n.  hal ini penting digunakan untuk menghitung gerbong.  
`soal=ARGV[2]` Mengambil argumen yang diketik di terminal.  ([0]=program yang digunakan(awk),[1]=file yang dibaca(passenger.csv),[2]=argumen tambahan(untuk soal ini a/b/c/d/e)). Argumen disimpan di variabel bernama soal.  
`delete ARGV[2]` Menghapus argumen agar tidak dibuka awk dan menyebabkan error.  
`total_usia=0` & `usia_tertua=0` menyiapkan variabel untuk digunakan dengan nilai awal 0. 

#### Pemrosesan Data

![soal1Main](assets/soal1Main.png)

Blok ini diawali dengan `NR>1` yang dimana menyatakan bahwa program didalam kurung kurawal hanya berlaku untuk baris ke-2 dan seterusnya. hal ini dilakukan agar bagian header tidak terbaca dan menyebabkan error.  

`jumlah_penumpang++` digunakan untuk menghitung berapa banyak orang yang ada di data.  

```shell
if(!gerbong[$4]++){
		jumlah_gerbong++
	}
```  
ini adalah program untuk menghitung gerbong

