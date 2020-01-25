package jsoncsv;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.util.HashMap;
import java.util.HashSet;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

/**
 *
 * @author steve
 *
 */
public class CSVDecoder {
	private Reader reader = null;
	private Writer errorWriter = null;
	private CSVParser parser = null;
	private String[] headerNames = null;

	public CSVDecoder(Reader reader, Writer errorWriter) {
		this.reader = reader;
		this.errorWriter = errorWriter;
	}

	/**
	 * Process the CSV stream, and put result to the target JSON encoder.
	 * @return 0 if success, non-zero for any error.
	 */
	public int process(JsonEncoder encoder) {
		try {
			Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_PARSE_CSV);
			try {
				parser = CSVParser.parse(this.reader,  CSVFormat.ORACLE);
			} catch (IOException e) {
				throw new ConverterException(Messages.FAIL_READ_CSV);
			}

			boolean arrayEncodingStarted = false;
			boolean firstRecord = true;
			for (CSVRecord record : parser) {
				if (record.size() == 0) {
					continue; // Empty record
				}
				if (record.size() == 1 && record.get(0).equals("")) {
					continue; // Empty record
				}

				if (firstRecord) { // First record is taken as header names
					processHeaderNames(record, encoder);
					firstRecord = false;
					encoder.startArray();
					arrayEncodingStarted = true;
				} else {
					processRecord(record, encoder);
				}
			}

			if (arrayEncodingStarted) {
				encoder.endArray();
			}
			Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_PARSE_CSV);
		} catch (ConverterException e) {
			Logger.log(LogLevel.LOG_ERROR, e);
			try {
				this.errorWriter.append(e.getMessage()).append("\n");
				this.errorWriter.flush();
				return e.getMsgId();
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
				return Messages.FAIL_WRITE_ERROR;
			}
		}

		return 0;
	}

	private void processHeaderNames(CSVRecord record, JsonEncoder encoder) throws ConverterException {
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_PARSE_CSV_HEADER);
		if (record.size() == 0) {
			throw new ConverterException(Messages.EMPTY_CSV_HEADER);
		}

		HashSet<String> uniqueHeaderNames = new HashSet<String>();
		this.headerNames = new String[record.size()];
		int arrayIndex = 0;

		for (String s : record) {
			if (uniqueHeaderNames.contains(s)) {
				throw new ConverterException(Messages.DUP_HEADER_NAME, s);
			} else {
				uniqueHeaderNames.add(s);
			}

			headerNames[arrayIndex++] = s;
		}

		if (headerNames.length == 1 && headerNames[0].equals("")) {
			throw new ConverterException(Messages.EMPTY_CSV_HEADER);
		}
		encoder.setPropertyNames(headerNames);
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_PARSE_CSV_HEADER);
	}

	private void processRecord(CSVRecord record, JsonEncoder encoder) throws ConverterException {
		// Report error if value count is greater than header count.
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_PARSE_CSV_RECORD);
		if (record.size() > this.headerNames.length) {
			throw new ConverterException(Messages.EXTRA_CSV_COLUMNS, record.getRecordNumber());
		}

		HashMap<String, Object> objectProperties = new HashMap<String, Object>();
		for (int index  = 0; index < record.size(); index++) {
			String s = record.get(index);
			if (s == null || s.length() == 0) {
				objectProperties.put(headerNames[index], null);
			} else {
				if (s.equals("\\N")) { // This is the null value in the format CSVFormat.ORACLE
					objectProperties.put(headerNames[index], null);
				} else if (s.compareToIgnoreCase("true") == 0) {
					objectProperties.put(headerNames[index], true);
				} else if (s.compareToIgnoreCase("false") == 0) {
					objectProperties.put(headerNames[index], false);
				} else {
					// If this value can be converted to double type, we will take it as a number.
					if (NumericValue.isNumeric(s)) {
						objectProperties.put(headerNames[index], new NumericValue(s));
					} else {
						objectProperties.put(headerNames[index], s);
					}
				}
			}
		}

		encoder.encode(objectProperties);
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_PARSE_CSV_RECORD);
	}
}
