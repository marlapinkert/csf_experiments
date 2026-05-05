# questPlus-3par
Matlab implementation of the Quest+ adaptive algorithm (Watson, 2017) for a 3 parameters psychometric function (mean, sd &amp; symmetric lapse rate).

## Notes
- See the file 'example.m' for and example and instructions.
- To adapt it for a different function, one needs to change the psychometric function defined in “p_ri_cond.m” and the initialisation of the table containing the probability density over parameters, which is initialised by the function “set_unif_p_table.m”.
- After a certain number of trials, Quest+ suggests stimuli at the boundaries of the stimulus range, to reduce uncertainty about the lapse rate parameter. If the range is not symmetric around the estimates of the mean, this may result in a series of high intensity stimuli placed only at one end of the range (the one more distant from the  estimated mean). To avoid this when Quest+ suggests a stimulus at boundary, the code by default pick randomly the side, or alternatively by setting an option allows to place the stimulus at one of the "sweet points” of the psychometric slope (i.e. the points associated with the minimum expected variance of the estimated slope).
