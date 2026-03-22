#!/usr/bin/awk -f

BEGIN{
	FS=","
	RS="\r\n"
	soal=ARGV[2]
	delete ARGV[2]
	total_usia=0
	usia_tertua=0
}

NR>1{
	
	jumlah_penumpang++
	
	if(!gerbong[$4]++){
		jumlah_gerbong++
	}

	if($2>usia_tertua){
		usia_tertua=$2
		nama_tertua=$1
	}
	total_usia += $2

	if($3 == "Business"){
		penumpang_bisnis++
	}
}

END{
	rata_usia=int(total_usia/jumlah_penumpang)
	if(soal=="a"){
		print "Jumlah seluruh penumpang KANJ adalah " jumlah_penumpang " orang"
	} 
	else if(soal=="b"){
		print "Jumlah gerbong penumpang KANJ adalah " jumlah_gerbong
	} 
	else if(soal=="c"){
		print nama_tertua " adalah penumpang kereta tertua dengan usia " usia_tertua
	} 
	else if(soal=="d"){
		print "Rata-rata usia penumpang adalah " rata_usia " tahun"
	} 
	else if(soal=="e"){
		print "Jumlah penumpang business class ada " penumpang_bisnis " orang"
	} 
	else {
		print "Soal tak dikenal, tolong input a/b/c/d/e"
	}
}
