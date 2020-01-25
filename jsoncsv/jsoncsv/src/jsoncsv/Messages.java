package jsoncsv;

import java.util.HashMap;

/**
 * Error/Logging Messages collection.
 * @author steve
 *
 */
public class Messages {
	public static final int INVALID_CMD_LINE 		= 1;
	public static final int UNKNOWN_ERROR 			= 9999;
	public static final int EMPTY_CSV_HEADER 		= 1002;
	public static final int DUP_HEADER_NAME  		= 1003;
	public static final int EXTRA_CSV_COLUMNS  		= 1004;
	public static final int FIRST_JSON_OBJ_EMPTY  	= 1005;
	public static final int FAIL_WRITE_CSV  		= 1006;
	public static final int EXTRA_JSON_PROPERTY  	= 1007;
	public static final int FAIL_READ_JSON  		= 1008;
	public static final int FAIL_WRITE_JSON  		= 1009;
	public static final int JARR_SUPPORT_OBJ_ONLY  	= 1010;
	public static final int JOBJ_SUPPORT_PRI_ONLY  	= 1011;
	public static final int FAIL_READ_CSV  			= 1012;
	public static final int FAIL_WRITE_ERROR  		= 1013;
	public static final int FAIL_WRITE_LOG  		= 1014;

	// Logging informations.
	public static final int LOG_START_PARSE_CSV				= 2001;
	public static final int LOG_END_PARSE_CSV				= 2002;
	public static final int LOG_START_PARSE_CSV_HEADER		= 2003;
	public static final int LOG_END_PARSE_CSV_HEADER		= 2004;
	public static final int LOG_START_PARSE_CSV_RECORD		= 2005;
	public static final int LOG_END_PARSE_CSV_RECORD		= 2006;
	public static final int LOG_START_PARSE_JSON			= 2007;
	public static final int LOG_END_PARSE_JSON				= 2008;
	public static final int LOG_START_PARSE_JSON_ARRAY		= 2009;
	public static final int LOG_END_PARSE_JSON_ARRAY		= 2010;
	public static final int LOG_START_PARSE_JSON_OBJ		= 2011;
	public static final int LOG_END_PARSE_JSON_OBJ			= 2012;
	public static final int LOG_START_ENCODE_CSV_HEADER		= 2013;
	public static final int LOG_END_ENCODE_CSV_HEADER		= 2014;
	public static final int LOG_START_ENCODE_CSV_RECORD		= 2015;
	public static final int LOG_END_ENCODE_CSV_RECORD		= 2016;
	public static final int LOG_START_ENCODE_JSON_ARR_BEGIN	= 2017;
	public static final int LOG_END_ENCODE_JSON_ARR_BEGIN	= 2018;
	public static final int LOG_START_ENCODE_JSON_ARR_END	= 2019;
	public static final int LOG_END_ENCODE_JSON_ARR_END		= 2020;
	public static final int LOG_START_ENCODE_JSON_OBJ		= 2021;
	public static final int LOG_END_ENCODE_JSON_OBJ			= 2022;
	public static final int LOG_EXIT_CODE					= 2023;


	private static final HashMap<Integer, String> messages = new HashMap<Integer, String>() {{
        put(INVALID_CMD_LINE, 		"Usage:\n\tcommand -[fromJson|fromCSV] [-log [NONE|ERROR|WARN|INFO|DEBUG]]");
        put(UNKNOWN_ERROR, 			"Unknown error.");
        put(EMPTY_CSV_HEADER, 		"Empty CSV record can not be taken as CSV header.");
        put(DUP_HEADER_NAME,  		"Duplicate CSV header name %s.");
        put(EXTRA_CSV_COLUMNS,		"The CSV record at line %d has extra items.");
        put(FIRST_JSON_OBJ_EMPTY,	"Cannot convert JSON stream into CSV while the first JSON object is empty.");
        put(FAIL_WRITE_CSV,			"Cannot write to target CSV file.");
        put(EXTRA_JSON_PROPERTY,	"Could not convert extra JSON object property %s to CSV. Make sure the first JSON object contains every required property.");
        put(FAIL_READ_JSON,			"Cannot read source JSON file.");
        put(FAIL_WRITE_JSON,		"Cannot to target JSON file.");
        put(JARR_SUPPORT_OBJ_ONLY,	"The top level array of source JSON can not contains elements other than objects.");
        put(JOBJ_SUPPORT_PRI_ONLY,	"The JSON object cannot contain nested array or object.");
        put(FAIL_READ_CSV,			"Cannot read source CSV file.");
        put(FAIL_WRITE_ERROR,		"Cannot write error info.");
        put(FAIL_WRITE_LOG,			"Cannot write log info.");

        // Logging informations
        put(LOG_START_PARSE_CSV,				"Start parsing CSV stream.");
        put(LOG_END_PARSE_CSV,					"End parsing CSV stream.");
        put(LOG_START_PARSE_CSV_HEADER,			"Start parsing CSV header.");
        put(LOG_END_PARSE_CSV_HEADER,			"End parsing CSV header.");
        put(LOG_START_PARSE_CSV_RECORD,			"Start parsing a CSV record.");
        put(LOG_END_PARSE_CSV_RECORD,			"End parsing a CSV record.");
        put(LOG_START_PARSE_JSON,				"Start parsing JSON stream.");
        put(LOG_END_PARSE_JSON,					"End parsing JSON strream.");
        put(LOG_START_PARSE_JSON_ARRAY,			"Start parsing JSON array.");
        put(LOG_END_PARSE_JSON_ARRAY,			"End parsing JSON array.");
        put(LOG_START_PARSE_JSON_OBJ,			"Start parsing a JSON object.");
        put(LOG_END_PARSE_JSON_OBJ,				"End parsing a JSON object.");
        put(LOG_START_ENCODE_CSV_HEADER,		"Start encoding CSV header.");
        put(LOG_END_ENCODE_CSV_HEADER,			"End encoding CSV header.");
        put(LOG_START_ENCODE_CSV_RECORD,		"Start encoding a CSV record.");
        put(LOG_END_ENCODE_CSV_RECORD,			"End encoding a CSV record.");
        put(LOG_START_ENCODE_JSON_ARR_BEGIN,	"Start encoding JSON array begin.");
        put(LOG_END_ENCODE_JSON_ARR_BEGIN,		"End encoding JSON array begin.");
        put(LOG_START_ENCODE_JSON_ARR_END,		"Start encoding JSON array end.");
        put(LOG_END_ENCODE_JSON_ARR_END,		"End encodig JSON array end.");
        put(LOG_START_ENCODE_JSON_OBJ,			"Start encoding a JSON object.");
        put(LOG_END_ENCODE_JSON_OBJ,			"End encoding a JSON object.");
        put(LOG_EXIT_CODE,						"Exit code: %d");

    }};

    public static String getMessage(int msgId) {
    	if (messages.containsKey(msgId)) {
    		return messages.get(msgId);
    	} else {
    		return null;
    	}
    }
}
