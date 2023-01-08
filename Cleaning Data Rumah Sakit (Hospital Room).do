/*
********************************************************************************
Generate Hospital Room Available Data (normal and isolation room)
	Name			: Fajar Nurhaditia Putra
	Data Source		: Ministry of Health
	Date of Modif.	: 21 April 2020
********************************************************************************

*/

clear
capture log close 
set more off 
global path "C:\Users\Angga Susatya\Google Drive\FAJAR-BAPPENAS\COVID19-IPEI"
cd "$path\IN\Hospital_room"
log using $path\OUT\data_jumlah_kamar_rs_indonesia, replace text 

******************************** Hospital Room Availability Data ************************************ ;
** Data Faskes
import delimited "Faskes - Rumah Sakit.csv", delimiter(comma)
drop v1
rename kode_rs satker
save $path\OUT\data_faskes, replace

**Data Ruang Umum
import delimited "data_kamar_summary-20200406-1304.csv", delimiter(comma) clear
rename ( total_kamar terisi_lk terisi_pr total_terisi kosong_lk kosong_pr total_kosong waiting_list) kamar_=
save $path\OUT\data_kamar_umum, replace

** Data Ruang Isolasi
import delimited "data_kamar_isolasi_detail-20200407-1322.csv", delimiter(comma) clear
rename kosong_lk str_kosong_lk
rename kosong_pr str_kosong_pr
rename waiting_list str_waiting_list
gen kosong_lk = real( str_kosong_lk)
gen kosong_pr = real( str_kosong_pr)
gen waiting_list = real(str_waiting_list)
drop str_kosong_lk str_kosong_pr str_waiting_list
drop nama alamat ruang kelas
bysort satker: gen dup = cond(_N==1,0,_n)
bysort satker: egen total_kamar_all = sum( total_kamar)
bysort satker: egen terisi_lk_all = sum( terisi_lk )
bysort satker: egen terisi_pr_all = sum( terisi_pr )
bysort satker: egen total_terisi_all = sum( total_terisi )
bysort satker: egen total_kosong_all = sum( total_kosong )
bysort satker: egen kosong_lk_all = sum( kosong_lk )
bysort satker: egen kosong_pr_all = sum( kosong_pr )
bysort satker: egen waiting_list_all = sum( waiting_list )
keep if dup == 0 | dup == 1
drop total_kamar terisi_lk terisi_pr total_terisi total_kosong kosong_lk kosong_pr waiting_list dup
rename ( last_update total_kamar_all terisi_lk_all terisi_pr_all total_terisi_all total_kosong_all kosong_lk_all kosong_pr_all waiting_list_all) isol_=
save OUT/data_kamar_isolasi, replace

**** MERGE DATA
use $path\OUT\data_faskes, clear
merge 1:1 satker using $path\OUT\data_kamar_umum
keep if _m == 3
drop _m
merge 1:1 satker using $path\OUT\data_kamar_isolasi
drop _m
** generate kab_id
tostring satker, gen(satker_str)
replace satker_str = substr( satker_str,1,4)
gen kab_id = real( satker_str)
order prov_id kab_id
drop satker_str
save $path\OUT\data_jumlah_kamar_rs_indonesia, replace



log close

