package jsoncsv;

import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;

public class JsonCSV {

	/**
	 * The usage of the command line is:
	 * command -[fromJson|fromCSV] [-log NONE]
	 * @param args
	 */
	public static void main(String[] args) {
		boolean fromJson = true;
		boolean errorCmdLine = false;

		if (!((args.length == 1) || (args.length == 3))) {
			errorCmdLine = true;
		}

		if (!errorCmdLine) {
			if (args.length >= 1) {
				String direction = args[0];
				if (direction.equals("-fromJson")) {
					fromJson = true;
				} else if (direction.equals("-fromCSV")) {
					fromJson = false;
				} else {
					errorCmdLine = true;
				}
			}

			if (!errorCmdLine && args.length == 3) {
				if (!args[1].equals("-log")) {
					errorCmdLine = true;
				}

				if (!errorCmdLine) {
					if (!Logger.initLogger(args[2])) {
						errorCmdLine = true;
					}
				}

			}
		}

		if (errorCmdLine) {
			System.err.println(Messages.getMessage(Messages.INVALID_CMD_LINE));
			System.exit(Messages.INVALID_CMD_LINE);
		}

		int exitCode = 0;
		InputStreamReader reader = new InputStreamReader(System.in);
		OutputStreamWriter writer = new OutputStreamWriter(System.out);
		OutputStreamWriter errorWriter = new OutputStreamWriter(System.err);
		if (fromJson) {
			exitCode = Json2CSV(reader, writer,  errorWriter);
		} else {
			exitCode = CSV2Json(reader, writer,  errorWriter);
		}

		Logger.log(LogLevel.LOG_INFO, String.format(Messages.getMessage(Messages.LOG_EXIT_CODE), exitCode));
		try {
			reader.close();
		} catch (Exception e) {
		}

		try {
			writer.close();
		} catch (Exception e) {
		}

		try {
			errorWriter.close();
		} catch (Exception e) {
		}

		System.exit(exitCode);
	}

	/**
	 * Entry method to conver JSON to CSV
	 * @param reader
	 * @param writer
	 * @param errorWriter
	 * @return
	 */
	public static int Json2CSV(Reader reader, Writer writer, Writer errorWriter) {
		JsonDecoder decoder = new JsonDecoder(reader, errorWriter);
		CSVEncoder encoder = new CSVEncoder(writer);

		return decoder.process(encoder);
	}

	/**
	 * Entry method to convert CSV to JSON.
	 * @param reader
	 * @param writer
	 * @param errorWriter
	 * @return
	 */
	public static int CSV2Json(Reader reader, Writer writer, Writer errorWriter) {
		CSVDecoder decoder = new CSVDecoder(reader, errorWriter);
		JsonEncoder encoder = new JsonEncoder(writer);

		return decoder.process(encoder);
	}

}
