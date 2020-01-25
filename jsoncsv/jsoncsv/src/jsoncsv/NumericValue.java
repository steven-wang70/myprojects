package jsoncsv;

/**
 * Instead of converting a numeric string literal to a numeric value like Double or Integer,
 * we keep the original string literal in this class definition because:
 * 1. There is no calculation among these numbers, so no conversion required at all;
 * 2. The numeric literal can be any type of number, conversion may cause loss of precision.
 * @author steve
 *
 */
public class NumericValue {
	private String numString = null;

	public NumericValue(String num) {
		this.numString = num;
	}

	public String getNumString() {
		return this.numString;
	}

	/**
	 * Check whether the passed in string represents a numeric value.
	 * As long as a string literal can be converted to a double value, it is a valid number string literal.
	 * @param s
	 * @return
	 */
	public static boolean isNumeric(String s) {
		try {
			Double.parseDouble(s);
			return true;
		} catch(NumberFormatException e){
			return false;
		}
	}
}
