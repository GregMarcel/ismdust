# ismdust

Contains calculations and fitting codes (ISIS table models and XSPEC models) from Corrales et. al. (2016)

http://arxiv.org/abs/1602.01100

To download, use git to create an ismdust folder:

        git clone https://github.com/eblur/ismdust.git ismdust

## Setup for ISMdust

Enter the ismdust directory and start XSPEC

    XSPEC12> initpackage ismdust lmodel_ismdust.dat .
    XSPEC12> exit

Finally, set an environment variable to point to location of ismdust, e.g.

    export ISMDUSTROOT=/path/to/ismdust/

Now, when you want to load the ISMDUST model in XSPEC, load the correct library. The following example loads ismdust and then applies the extinction model to a power law component:

    XSPEC12> load libismdust.dylib
    XSPEC12> mo ismdust*pow
    
Try the test file to make sure it's working.

    XSPEC12> @test.xcm

## Setup for ismdust fits with ISIS (Interactive Spectral Interpretation System) models

Add a line to your .isisrc file

    add_to_isis_load_path("/path/to/ismdust/ismdust_isis");

Set an environment variable (same way you would for the XSPEC model)

    export ISMDUSTROOT=/path/to/ismdust/

When you want to invoke the model, use the require function in ISIS to load ismdust

    isis> require("ismdust");

To set up the model extinction model with a power law continuum, for example, do:

    isis> fit_fun("ismdust(1, powerlaw(1))");

## Setup for Fe-L edge fits with ISIS (Interactive Spectral Interpretation System) models

Add a line to your .isisrc file

    add_to_isis_load_path("/path/to/ismdust/ismdust_isis");

Set an environment variable to point to the location of the Fe-L edge templates:

    export FEPATH=/path/to/ismdust/ismdust_isis/

When you want to invoke the model, use the require function in ISIS to load the model.

    isis> require("FeLedge");

To invoke the model:

    isis> fit_fun("FeLedge(1, powerlaw(1))");
