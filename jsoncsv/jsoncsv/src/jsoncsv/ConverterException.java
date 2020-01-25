package jsoncsv;

public class ConverterException extends Exception {
	private static final long serialVersionUID = 1L;

	private int msgId;
	private String msg;

	public ConverterException(int msgId, Object... args) {
		this.msgId = msgId;
		this.msg = String.format(Messages.getMessage(this.msgId), args);
	}

	public int getMsgId() {
		return this.msgId;
	}

	@Override
	public String getMessage() {
		return this.msg;
	}
}
