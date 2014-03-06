#File: histolog.awk
# HISTOLOG.AWK from http://www.esmerel.com/wagons/rob/scripts.html
#
#    Written 97-01-07
#    By      Rob Ewan
#
# This is an AWK program to convert a timestamped log into a chart of number
# of messages versus time.
# Normally, the log file will have been preparsed to extract the messages
# which are of interest.
# The script assumes that each line in the log will begin with a timestamp,
# but provides options for the timestamp to be elsewhere on the line.
#
# Usage:
#       AWK HISTOLOG [options] logFile(s)
#
# Options:
#       scale=nn    Set the scaling factor for the display          ( 1 )
#       field=n     Select field which contains the 'time' (0 - whole line)
#       column=n    Set where the 'time' starts within the field    ( 1 )
#       width=n     Set the width (characters) of the 'time' input  ( 2 )
#       fuzz=n      Display eith bars (0) or lines with error (1)   ( 0 )
#

# Put initialization code here
BEGIN {
    scale  = 1      # Each '*' corresponds to this count
    field  = 0      # Which field contains the 'time'
    column = 1      # Start of 'time' within the field
    width  = 2      # Width of the 'time' defining field
    fuzz   = 0      # Flag: Turn on to see 'error bars' on readings
    totalCounts = 0
}

# DUMP HISTOGRAM BAR - Draw one bar of the histogram
function DumpHistogramBar() {
    histoBar = ""
    # If we want 'error bars',
    if ( fuzz ) {
        # Generate lower/upper bound for reading
        lbound = nCounts - sqrt(nCounts);
        ubound = nCounts + sqrt(nCounts);
        # Generate a two-colour bar to show the reading
        for ( i = 0; i < ((ubound+scale-1)/scale); i++ ) {
            if ( (i+1)*scale <= lbound ) {
                histoBar = histoBar " "
            } else if ( i*scale < nCounts ) {
                histoBar = histoBar "*"
            } else {
                histoBar = histoBar "+"
            }
        }
    # Otherwise, just a straight histogram
    } else {
      for ( i = 0; i < ((nCounts+scale-1)/scale); i++) {
            histoBar = histoBar "*"
        }
    }
    printf( "%" width "s - %3d: %s\n", oldTime, nCounts, histoBar );
    totalCounts += nCounts;
}

# SHOW OPTIONS - List the current values of the options (for heading)
function ShowOptions( fileName) {
    printf( "%s - Scale: %d, Time width: %d", fileName, scale, width );
    if ( fuzz ) printf( ", with fuzz bars" );
    printf( "\n" );
}

# Now put the active code. pattern { action }
{ used = 0 }

/^File/ {
    ShowOptions( $0 );
    used = 1
}

!used {
    timeStr = substr( $field, column, width );
    if ( timeStr == oldTime ) {
        nCounts++;
    } else {
        if ( oldTime != "") DumpHistogramBar();
        oldTime = timeStr;
        nCounts = 1;
    }
}

END {
    if ( nCounts > 0 ) DumpHistogramBar();
    print "Total counts = " totalCounts
}
