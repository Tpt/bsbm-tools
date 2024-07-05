package benchmark.testdriver;

import benchmark.qualification.QueryResult;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;

public class InterceptingConnection implements ServerConnection {
    PrintWriter output;

    public InterceptingConnection() {
        try {
            this.output = new PrintWriter(new File("log.csv"));
        } catch (FileNotFoundException e) {
            throw new RuntimeException(e);
        }
        this.output.write("id,kind,content\n");
    }

    @Override
    public void executeQuery(Query query, byte queryType) {
        this.log(query.getQueryString(), queryType, query.getNr());
        query.getQueryMix().setCurrent(0, 0.);
    }

    @Override
    public void executeQuery(CompiledQuery query, CompiledQueryMix queryMix) {
        this.log(query.getQueryString(), query.getQueryType(), query.getNr());
        queryMix.setCurrent(0, 0.);
    }

    @Override
    public QueryResult executeValidation(Query query, byte queryType) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void close() {
        this.output.close();
    }

    private void log(String queryString, byte queryType, int nr) {
        this.output.write(nr + "," + (queryType == Query.UPDATE_TYPE ? "update" : "query") + "," + escapeCsv(queryString) + "\n");
    }

    private String escapeCsv(String data) {
        data = data.replaceAll("\\R+", " ");
        if (data.contains(",") || data.contains("\"") || data.contains("'")) {
            data = data.replace("\"", "\"\"");
            data = "\"" + data + "\"";
        }
        return data;
    }
}
