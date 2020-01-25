package jsoncsv;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.util.ArrayList;
import java.util.HashMap;

import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonToken;

/**
 * To convert a json stream to CSV format, the json value must comply with this convention:
 * 1. The value can be a single object or an array of objects;
 * 2. The object can not contain nested arrays or objects. Otherwise it will report error;
 * 3. The first object of the array will be used to generate the header of CSV. Any following object item
 * which has extra elements will cause error. Missing element is taken as null;
 * 4. Empty content will cause error since we could not generate CSV header from it.
 * @author steven
 *
 */
public class JsonDecoder {
	private JsonReader jsonReader = null;
	private Writer errorWriter = null;
	private boolean firstObject = true;

	public JsonDecoder(Reader reader, Writer errorWriter)
	{
		this.jsonReader = new JsonReader(reader);
		this.jsonReader.setLenient(true); // Configure this parser to be liberal in what it accepts.
		this.errorWriter = errorWriter;
	}

	/**
	 * Process the JSON stream, and put result to the target CSV encoder.
	 * @return 0 if success, non-zero for any error.
	 */
	public int process(CSVEncoder encoder) {
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_PARSE_JSON);
        try
        {
    		JsonToken nextToken;
			try {
				nextToken = jsonReader.peek();
			} catch (IOException e) {
				throw new ConverterException(Messages.FAIL_READ_JSON);
			}

    		if (JsonToken.BEGIN_OBJECT.equals(nextToken)) {
    			processSingleObject(encoder);

    		} else if (JsonToken.BEGIN_ARRAY.equals(nextToken)) {
    			processObjectArray(encoder);

    		}
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
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_PARSE_JSON);

        return 0;
	}

	private void processObjectArray(CSVEncoder encoder) throws ConverterException {
		try {
			Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_PARSE_JSON_ARRAY);
			jsonReader.beginArray();

	        while (true)
	        {
	            JsonToken nextToken = jsonReader.peek();

	            if (JsonToken.END_ARRAY.equals(nextToken)) {
	            	jsonReader.endArray();
	            	break;

	            } else if (JsonToken.BEGIN_OBJECT.equals(nextToken)) {
	            	processSingleObject(encoder);

	            } else {
	            	throw new ConverterException(Messages.JARR_SUPPORT_OBJ_ONLY); // Only object allowed in array
	            }
	        }
		} catch (IOException e) {
			throw new ConverterException(Messages.FAIL_READ_JSON);
		}
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_PARSE_JSON_ARRAY);
	}

	private void processSingleObject(CSVEncoder encoder) throws ConverterException {
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_START_PARSE_JSON_OBJ);
		// This map is used to hold object values for each JSON object.
		// It is mapped to a line of CSV accordingly.
		HashMap<String, Object> objectProperties = new HashMap<String, Object>();
		ArrayList<String> propertyNamesInOrder = null;
		if (this.firstObject) {
			propertyNamesInOrder = new ArrayList<String>();
			this.firstObject = false;
		}

		String propertyName = null;

		try {
			jsonReader.beginObject();

	        while (true)
	        {
	            JsonToken nextToken = jsonReader.peek();

	            if (JsonToken.END_OBJECT.equals(nextToken)) {
	            	jsonReader.endObject();
	            	if (propertyNamesInOrder != null) {
	                	encoder.encodeHeader(propertyNamesInOrder);
	                	propertyNamesInOrder = null;
	            	}
	            	encoder.encode(objectProperties);
	            	objectProperties.clear();
	            	break;

	            } else if (JsonToken.BEGIN_ARRAY.equals(nextToken)) {
	            	throw new ConverterException(Messages.JOBJ_SUPPORT_PRI_ONLY); // Object can not contain nested array

	            } else if (JsonToken.BEGIN_OBJECT.equals(nextToken)) {
		        	throw new ConverterException(Messages.JOBJ_SUPPORT_PRI_ONLY); // Object can not contain nested object

		        } else if (JsonToken.NAME.equals(nextToken)) {
		        	propertyName = jsonReader.nextName();
		        	if (propertyNamesInOrder != null) {
		        		propertyNamesInOrder.add(propertyName);
		        	}

	            } else if (JsonToken.STRING.equals(nextToken)) {
	                String value = jsonReader.nextString();
	                objectProperties.put(propertyName, value);
	                propertyName = null;

	            } else if (JsonToken.NUMBER.equals(nextToken)) {
	                String value = jsonReader.nextString();
	                objectProperties.put(propertyName, new NumericValue(value));
	                propertyName = null;

	            } else if (JsonToken.BOOLEAN.equals(nextToken)) {
	                boolean value = jsonReader.nextBoolean();
	                objectProperties.put(propertyName, value);
	                propertyName = null;

	            } else if (JsonToken.NULL.equals(nextToken)) {
	                jsonReader.nextNull();
	                objectProperties.put(propertyName, null);
	                propertyName = null;

	            }
	        }
        } catch (IOException e) {
			throw new ConverterException(Messages.FAIL_READ_JSON);
		}
		Logger.log(LogLevel.LOG_INFO, Messages.LOG_END_PARSE_JSON_OBJ);
	}
}

