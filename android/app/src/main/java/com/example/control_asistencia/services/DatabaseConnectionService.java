package com.example.control_asistencia.services;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.example.control_asistencia.models.Face;

import java.util.ArrayList;

public class DatabaseConnectionService extends SQLiteOpenHelper {

    private static final int DB_VERSION = 1;
    private static final String DB_NAME = "facesSDK";
    private static final String CREATE_IMAGES_TABLE = "" +
            "CREATE TABLE IF NOT EXISTS userFaces (" +
            "id INTEGER PRIMARY KEY," +
            "userId INTEGER NOT NULL," +
            "template BLOB NOT NULL" +
            ")";
    private static DatabaseConnectionService connection;
    private SQLiteDatabase db;

    //constructor
    private DatabaseConnectionService() {
        super( null ,DB_NAME, null, DB_VERSION);
    }

    public static DatabaseConnectionService getInstance() {
        if (connection == null) {
            connection = new DatabaseConnectionService();
        }
        return connection;
    }



    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(CREATE_IMAGES_TABLE);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS userFaces");
        onCreate(db);
    }

    public void insertFaceToDB(Face face) {
        ContentValues cv = new ContentValues();
        cv.put("userId", face.getUserId());
        cv.put("template", face.getTemplate());
        if (db == null) {
            db = connection.getWritableDatabase();
        }
        db.insert("userFaces", null, cv);
    }

    public ArrayList<Face> getFaces() {
        ArrayList<Face> list = new ArrayList<Face>();
        if (db == null) {
            db = connection.getReadableDatabase();
        }
        Cursor c = db.rawQuery("select userId, template from userFaces", null);
        if (c != null && c.getCount()>0) {
            c.moveToFirst();
            do {
                int userId = c.getInt(c.getColumnIndex("userId"));
                byte[] template = c.getBlob(c.getColumnIndex("id"));
                Face face = new Face(userId, template);
                list.add(face);
            } while (c.moveToNext());
        }
        c.close();
        db.close();
        return list;
    }

    @Override
    public synchronized void close() {
        super.close();
    }
}
