package jsoncsv;

/**
 * Log level enum definition.
 * @author steve
 *
 */
public enum LogLevel {
	LOG_NONE(0, "NONE"),
	LOG_ERROR(1, "ERROR"),
	LOG_WARN(2, "WARN"),
	LOG_INFO(3, "INFO"),
	LOG_DEBUG(4, "DEBUG");

	private final int value;
	private final String name;
	private LogLevel(int value, String name) {
		this.value = value;
		this.name = name;
	}

	public int getValue() {
		return this.value;
	}

	public String getName() {
		return this.name;
	}
}
