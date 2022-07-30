*! 1.0.0 Agustin Staudt 12agosto2021
program define valcuit
	version 8
	syntax varlist(string max=1) [if] [in], GENerate(name) [clean(name)]
	marksample touse, novarlist
	if "`generate'"=="`clean'"{
			di as error "La variable indicador creada con gen() " ///
						"y la creada con clean() no pueden llamarse igual."
			error 198
	}
	* condición fatal si no hay observaciones
	qui count if `touse'
	if r(N) == 0 error 2000
	* CUIT debe ser numérica. Si no lo es, emite un mensaje de error
	if "`clean'"=="" {
		  qui count if real(`varlist') >= . & `touse'
		  if r(N)!= 0 {
				di as error "En la variable" " `varlist' " ///
							"existen caracteres no numéricos." ///
				_newline `"Use la opción -clean()- para solucionarlo."'
		  error 9
		  }
	}
	if "`clean'"!="" {
			qui g `clean'= ""   
			tempvar largo
			qui g byte `largo' = length(`varlist') if `touse'
			summ `largo' if `touse', meanonly
			forval i = 1/`r(max)' {
				  qui replace `clean'= `clean' + substr(`varlist',`i',1) ///
						 if inrange(substr(`varlist',`i',1),"0","9") & `touse'
			}
			drop `largo'
			local et_var: variable label `varlist'
			label variable `clean' "`et_var' - Sólo caracteres numéricos" 
			loc varlist `clean'
	}	
	g byte `generate'=0
	* cuit debe tener 11 dígitos
	qui replace `generate' = 1 if length(`varlist') != 11 & `touse' & `generate'==0
	* 20, 23, 24, 27, 30, 33, 34 prefijos válidos
	qui replace `generate' = 1 if ///
			!inlist(real(substr(`varlist', 1, 2)), 20, 23, 24, 27, 30, 33, 34) ///
        & `touse' & `generate' == 0
	* número central distinto de 0	
	qui replace `generate' = 1 if substr(`varlist',3,8)=="00000000" ///
										& `touse' & `generate' == 0	
	* verificación del dígito de verificación 
	tempvar suma
	qui g int `suma'=0	
	forvalues i=1/11 {
		qui replace `suma' = `suma' + real(substr(`varlist',`i', 1)) * ///           
								real(substr("54327654321",`i', 1)) 
	}
	* modalidad: módulo “11”, base “7” y resto “0”
	qui replace `generate' = 1 if mod(`suma', 11) != 0 & `touse' & `generate'==0		
	* conteo de CUIT's inválidos
	qui count if `generate' == 1
	di as text "Hay `r(N)' CUIT's inválidas."
	if r(N) == 0 {
		drop `generate' `clean'
	}

end



		