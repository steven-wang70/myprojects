package test;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.StringReader;

import jsoncsv.JsonCSV;
import jsoncsv.Logger;

/**
 * This is the entry of test cases that would test complicated scenarios.
 * The test read input from stdin, and output result together with error/logging to stdout.
 * The input format is content separated with ten right arrows >>>>>>>>>>
 * Each test is reset the logging level to NONE. At the beginning of the content, ten left arrows
 * is the definition of logging level like : <<<<<<<<<< WARN
 *
 * The command format is:
 * test -[fromCSV|fromJson]
 * @author steve
 *
 */
public class TestCases {

	public static void main(String[] args) {
		String direction = args[0];
		boolean fromJson = true;

		if (direction.equals("-fromJson")) {
			fromJson = true;
		} else if (direction.equals("-fromCSV")) {
			fromJson = false;
		} else {
			// Wrong command line option
			System.err.print("Wrong command line options");
			System.exit(1);
		}

		try {
			final String SEPARATOR_LINE = ">>>>>>>>>>";
			final String LOG_LEVEL = "<<<<<<<<<<";
			StringBuffer sourceContent = new StringBuffer();
			String logLevel = "NONE";

			BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
			String line = null;
			while ((line = reader.readLine()) != null) {
				if (line.startsWith(SEPARATOR_LINE)) {
					if (sourceContent.length() > 0) {
						convert(sourceContent, fromJson, logLevel);

						// Reset everything.
						sourceContent = new StringBuffer();
					}
					logLevel = "NONE";
					System.out.println(line);
				} else if(line.startsWith(LOG_LEVEL)) {
					logLevel = line.substring(LOG_LEVEL.length()).trim();
					System.out.println(line);
				} else {
					sourceContent.append(line).append('\n');
				}
			}

			if (sourceContent.length() > 0) {
				convert(sourceContent, fromJson, logLevel);
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private static void convert(StringBuffer content, boolean fromJson, String loglevel) {
		int exitCode = 0;
		Logger.initLogger(loglevel);
		StringReader reader = new StringReader(content.toString());
		OutputStreamWriter writer = new OutputStreamWriter(System.out);
		OutputStreamWriter errorWriter = new OutputStreamWriter(System.out);
		if (fromJson) {
			exitCode = JsonCSV.Json2CSV(reader, writer,  errorWriter);
		} else {
			exitCode = JsonCSV.CSV2Json(reader, writer,  errorWriter);
		}

		System.out.println(String.format("\n<<<<<<<<<< Exit code: %d", exitCode));
	}
}
