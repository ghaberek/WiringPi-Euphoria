include wiringPi.e

integer model, rev, mem, maker, overVolted
{model,rev,mem,maker,overVolted} = piBoardId()

printf( 1, "maker = %s\n", {piMakerNames[maker]} )
printf( 1, "model = %s\n", {piModelNames[model]} )
printf( 1, "mem   = %d\n", {piMemorySize[mem]} )
printf( 1, "rev   = %s\n", {piRevisionNames[rev]} )
