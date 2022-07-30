*gcuant2.do
*** Modificación del comando gcuant de la maestría en economía UNLP
* Autor: Agustin Staudt
capture program drop gcuant2
program define gcuant2, rclass sortpreserve
	syntax varlist(max=1) [if] [iweight] [,Ncuantiles(real 10) Generate(name local)]

	marksample touse

	local wt: word 2 of `exp'
	if "`wt'"=="" { 
	local wt = 1
	}
	
	* Ordenar por varlist
	sort `varlist', stable 

	* Variables temporales
	tempvar shrpop 
	
	* Computar orcentaje acumulado depob
	qui gen `shrpop' = sum(`wt') if `touse'
	qui sum `shrpop'
	loc shrpop_last=`r(max)'
	qui replace `shrpop' = (`shrpop'/`shrpop_last') if `touse'
	
	* Identifiacion deciles de `varlist'
	local proporcion = 1/`ncuantiles'
	cap noi gen `generate' = .
    if _rc == 110 {
        noisily dis as res "replacing variable `generate' already defined"
    }
	forvalues i = 1(1)`ncuantiles' {
				replace `generate' = `i' if (`shrpop'> (`i'-1)*`proporcion') & ///
									(`shrpop' <= `i'*`proporcion') & `touse'
	}

end

