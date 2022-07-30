*! 1.0.0 Agustin Staudt 25julio2021
program define sintilde
	version 8
	syntax varlist(string max=1), GENerate(name)
	qui {
		local tilde "á é í ó ú Á É Í Ó Ú à è ì ò ù À È Ì Ò Ù"
		local stilde "a e i o u A E I O U a e i o u A E I O U"
		local n : word count `tilde'
		
		clonevar  `generate' = `varlist'
		
		forvalues i = 1/`n' {
				 local con : word `i' of `tilde'
				 local sin : word `i' of `stilde'
				 replace `generate' = subinstr(`generate',"`con'","`sin'",.)
		}
	}
end
