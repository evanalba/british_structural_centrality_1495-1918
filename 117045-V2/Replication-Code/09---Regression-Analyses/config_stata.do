clear all
set more off

program main
    * *** Add required packages from SSC to this list ***
    local ssc_packages "ranktest" "ftools" "reghdfe" "ivreghdfe" "ivreg2" "estout"
    * *** Add required packages from SSC to this list ***

    if !missing("`ssc_packages'") {
        foreach pkg in "`ssc_packages'" {
            dis "Installing `pkg'"
            quietly ssc install `pkg', replace
        }
    }

    * Install packages using net
    quietly net from "https://raw.github.com/gvegayon/parallel/stable/"
    quietly cap ado uninstall parallel
    quietly net install parallel
	
end

main
