public class CS_AllBundleComplexPriceTriggerHelper {

    public static final String OVERLAPPING_BOUNDS_ERROR = 'Provided skill hour bounds overlap with existing bundle complex price: ';

    public class Bound {
    	Decimal lowerBound;
    	Decimal upperBound;

    	public Bound(Decimal lBound, Decimal uBound) {
    		lowerBound = lBound;
    		upperBound = uBound;
    	}

    	public Boolean overlaps(Bound second) {
	    	if (this.lowerBound < second.lowerBound) {
	    		if (this.upperBound > second.lowerBound) {
	    			return true;
	    		}
	    	} else if (this.lowerBound > second.lowerBound) {
	    		if (second.upperBound > this.lowerBound) {
	    			return true;
	    		}
	    	} else if (this.lowerBound == second.lowerBound) {
	    		return true;
	    	}
	    	return false;
    	}
    }
}