package jsoncsv;

import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * Logger definition.
 * Maybe changed to support server side logging, which is not clear yet.
 * @author steve
 *
 */
public class Logger {
	private static LogLevel logLevel = LogLevel.LOG_NONE;

	/**
	 * Try to init the log level with a string literal log level
	 * @param logLevel
	 * @return true for success, false if failed.
	 */
	public static boolean initLogger(String logLevel) {
		if (logLevel.equals(LogLevel.LOG_NONE.getName())) {
			Logger.logLevel = LogLevel.LOG_NONE;
			return true;
		} else if (logLevel.equals(LogLevel.LOG_ERROR.getName())) {
			Logger.logLevel = LogLevel.LOG_ERROR;
			return true;
		} else if (logLevel.equals(LogLevel.LOG_WARN.getName())) {
			Logger.logLevel = LogLevel.LOG_WARN;
			return true;
		} else if (logLevel.equals(LogLevel.LOG_INFO.getName())) {
			Logger.logLevel = LogLevel.LOG_INFO;
			return true;
		} else if (logLevel.equals(LogLevel.LOG_DEBUG.getName())) {
			Logger.logLevel = LogLevel.LOG_DEBUG;
			return true;
		} else {
			return false;
		}
	}

	private static void writeToLog(String msg) {
		System.err.println(msg);
	}

	public static void log(LogLevel level, String message) {
		if (level.getValue() <= logLevel.getValue()) {
			writeToLog(String.format("%s:%s", level.getName(), message));
		}
	}

	public static void log(LogLevel level, int msgId) {
		if (level.getValue() <= logLevel.getValue()) {
			writeToLog(String.format("%s:%s", level.getName(), Messages.getMessage(msgId)));
		}
	}

	public static void log(LogLevel level, Exception e) {
		if (level.getValue() <= logLevel.getValue()) {
			writeToLog(String.format("%s:%s", level.getName(), e.getMessage()));
			StringWriter sw = new StringWriter();
            e.printStackTrace(new PrintWriter(sw));
            String exceptionAsString = sw.toString();
			writeToLog(exceptionAsString);
		}
	}
}
