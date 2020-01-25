package jsoncsv;

import java.io.IOException;
import java.io.Writer;
import java.text.CharacterIterator;
import java.text.StringCharacterIterator;
import java.util.Map;

/**
 *
 * @author steve
 *
 */
public class JsonEncoder {
	private String[] propertyNames = null;
	private Writer writer = null;
	private boolean firstObject = true;

	public JsonEncoder(Writer writer) {
		this.writer = writer;
	}

	public void setPropertyNames(String[] propertyNames) {
		this.propertyNames = propertyNames;
	}

	private String escapeValue(Object v) throws ConverterException {
		if (v instanceof Boolean) {
			return v.toString();
		} else if (v instanceof NumericValue) {
			return ((NumericValue)v).getNumString();
		} else if (v instanceof String) { // For string value, we only escape double quote, newline, and slash
			String sv = (String)v;
			if (sv.indexOf('\\') >= 0 || sv.indexOf('\"') >= 0 || sv.indexOf('\n') >= 0) {
				StringBuffer sb = new StringBuffer();
				sb.append('\"');
				StringCharacterIterator it = new StringCharacterIterator(sv);
				while (it.current() != CharacterIterator.DONE) {
					char c = it.current();
					if (c == '\\' || c == '\"') {
						sb.append('\\').append(c);
					} else if ( c == '\n') {
						sb.append("\\n");
					} else {
						sb.append(c);
					}

					it.next();
				}

				sb.append('\"');
				return sb.toString();
			} else {
				return "\"" + sv + "\""; // Nothing to be escaped
			}
		}

		// We should not reach here.
		throw new ConverterException(Messages.UNKNOWN_ERROR);
	}

	public void encode(Map<String, Object> objectProperties) throws ConverterException {
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_ENCODE_JSON_OBJ);
		try {
			startObject();

			boolean firstProperty = true;
			for (String propertyName : this.propertyNames) {
				if (objectProperties.containsKey(propertyName)) {
					Object value = objectProperties.get(propertyName);
					if (value == null) {
						continue; // Omit null values.
					}

					if (firstProperty) {
						firstProperty = false;
					} else {
						writer.append(",");
					}

					writer.append("\n\t\t").append(escapeValue(propertyName)).append(" : ").append(escapeValue(value));
				}
			}

			endObject();
		} catch (IOException e) {
			throw new ConverterException(Messages.FAIL_WRITE_JSON);
		}
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_ENCODE_JSON_OBJ);
	}

	public void startArray() throws ConverterException {
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_ENCODE_JSON_ARR_BEGIN);
		try {
			this.writer.append("[");
		} catch (IOException e) {
			throw new ConverterException(Messages.FAIL_WRITE_JSON);
		}
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_ENCODE_JSON_ARR_BEGIN);
	}

	public void endArray() throws ConverterException {
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_ENCODE_JSON_ARR_END);
		try {
			this.writer.append("\n]");
			this.writer.flush();
		} catch (IOException e) {
			throw new ConverterException(Messages.FAIL_WRITE_JSON);
		}
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_ENCODE_JSON_ARR_END);
	}

	private void startObject() throws IOException {
		if (firstObject) {
			firstObject = false;
		} else {
			this.writer.append(",");
		}
		this.writer.append("\n\t{");
	}

	private void endObject() throws IOException {
		this.writer.append("\n\t}");
		this.writer.flush();
	}
}
