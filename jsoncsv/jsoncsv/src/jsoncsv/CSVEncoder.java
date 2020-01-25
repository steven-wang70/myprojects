package jsoncsv;

import java.io.IOException;
import java.io.Writer;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

public class CSVEncoder {
	private Writer writer;

	// Hold the initial object keys in this set. Any following objects could not comply with
	// this key set will report error. Use set for fast lookup
	private HashSet<String> headerNameSet = null;

	// This contains the same values as headers, but in its original order.
	// Keep the original order for readability.
	private List<String> headerNameList = null;

	public CSVEncoder(Writer writer) {
		this.writer = writer;
	}

	/**
	 * According to CSVFormat.ORACLE, it should escape double quote, slash and newline.
	 * See: https://commons.apache.org/proper/commons-csv/apidocs/org/apache/commons/csv/CSVFormat.html#ORACLE
	 * @param v
	 * @return
	 */
	private String escapeString(String v) {
		if (v.indexOf('\\') >= 0) {
			v = v.replaceAll("\\\\", "\\\\\\\\"); // Use \\\\ because it is escaped in both Java string and regex string.
		}

		if (v.indexOf('\"') >= 0) {
			v = v.replaceAll("\\\"", "\\\\\\\"");
		}

		if (v.indexOf('\n') >= 0) {
			v = v.replaceAll("\\\n", "\\\\\\n");
		}

		return v;
	}

	private String escapeNullValue() {
		return "\\N"; // This is the convention of CSVFormat.ORACLE for null.
	}

	/**
	 * We take the first line of CSV as header names.
	 * @param headers
	 * @throws ConverterException
	 */
	public void encodeHeader(List<String> headers) throws ConverterException {
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_ENCODE_CSV_HEADER);
		if (headers.size() == 0) {
			throw new ConverterException(Messages.FIRST_JSON_OBJ_EMPTY);
		}

		// Using a set to check uniqueness of header names.
		headerNameSet = new HashSet<String>();

		StringBuffer sb = new StringBuffer();
		boolean firstHeader = true;

		for (String header : headers) {
			if (firstHeader) {
				firstHeader = false;
			} else {
				sb.append(",");
			}

			String headerName = header.toString();

			sb.append("\"").append(escapeString(headerName)).append("\"");

			headerNameSet.add(headerName);
		}

		headerNameList = headers;
		sb.append("\n");

		try {
			writer.append(sb.toString());
			this.writer.flush();
		} catch (IOException e) {
			throw new ConverterException(Messages.FAIL_WRITE_CSV);
		}
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_ENCODE_CSV_HEADER);
	}

	/**
	 * In this method, we need to first check whether the new object properties are compatible
	 * with the existing headers.
	 * Then add the property in the order defined in the first JSON object.
	 * @param objectProperties
	 * @throws ConverterException
	 */
	public void encode(HashMap<String, Object> objectProperties) throws ConverterException {
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_ENCODE_CSV_RECORD);
		// Make sure each property name is in the header name set.
		for (String keyName : objectProperties.keySet()) {
			if (!headerNameSet.contains(keyName)) {
				throw new ConverterException(Messages.EXTRA_JSON_PROPERTY, keyName);
			}
		}

		StringBuffer sb = new StringBuffer();
		boolean firstValue = true;

		// Loop with the original headerNameList so they are always in the same order.
		for (String key : headerNameList) {
			if (firstValue) {
				firstValue = false;
			} else {
				sb.append(",");
			}

			Object value = null;
			if (objectProperties.containsKey(key)) {
				value = objectProperties.get(key);
			}

			if (value == null) {
				sb.append(escapeNullValue());
			} else if (value instanceof NumericValue) {
				NumericValue nv = (NumericValue)value;
				sb.append(nv.getNumString());
			} else {
				if (value instanceof String) {
					sb.append("\"").append(escapeString((String)value)).append("\"");
				} else {
					sb.append(value.toString());
				}

			}
		}

		sb.append("\n");

		try {
			writer.append(sb.toString());
			this.writer.flush();
		} catch (IOException e) {
			throw new ConverterException(Messages.FAIL_WRITE_CSV);
		}
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_ENCODE_CSV_RECORD);
	}
}
