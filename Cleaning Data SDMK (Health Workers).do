/*
********************************************************************************
Generate Health Human Resources Data
	Name			: Fajar Nurhaditia Putra
	Data Source		: Ministry of Health
	Date of Modif.	: 21 April 2020
********************************************************************************

*/
clear
capture log close 
set more off 
global path "C:\Users\Angga Susatya\Google Drive\FAJAR-BAPPENAS\COVID19-IPEI"
cd "$path\IN\Health_workers"
log using $path\OUT\data_jumlah_sdmk_rs_indonesia, replace text 

******************************** Health Human Resources Data ************************************ ;
** convert excel into stata
forvalues i = 00(1)34{
import excel "FASYANKES`i'.xlsx", sheet("Sheet1") firstrow allstring clear
save $path\OUT\fasyankes`i', replace
}

** appending all file into one file
use $path\OUT\fasyankes0, clear
forvalues i = 1(1)34{
append using $path\OUT\fasyankes`i'
}

** restructures and cleaning the final data
gen namaprovkab = NamaProvinsi
replace namaprovkab = NamaKabKota if namaprovkab == ""
drop namaprovkab
gen NamaProvKab = NamaProvinsi
replace NamaProvKab = NamaKabKota if NamaProvKab == ""
gen JumlahPerProvKab = JumlahPerProvinsi
replace JumlahPerProvKab = JumlahPerKabKota if JumlahPerProvKab == ""
drop JumlahPerKabKota JumlahPerProvinsi NamaProvinsi NamaKabKota

**create integer variable
foreach i in No JumlahUnit Medis PsikologiKlinis Keperawatan Kebidanan Kefarmasian ///
KesehatanMasyarakat KesehatanLingkungan Gizi KeterapianFisik KeteknisianMedis ///
TeknikBiomedika TenagaKesehatanTradisional TenagaPenunjangKesehatan JumlahPerProvKab {
gen r`i' = real(`i')
drop `i'
rename r`i' `i'
}
order No NamaProvKab
save $path\OUT\data_nakes_rs_indonesia, replace
export excel using "$path\OUT\data_sdmk_rs_indonesia.xls", firstrow(variables) replace

log close
