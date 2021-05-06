package com.example.control_asistencia.services;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.example.control_asistencia.models.Face;

import java.util.ArrayList;

public class DatabaseConnectionService extends SQLiteOpenHelper {

    private static final int DB_VERSION = 1;
    private static final String DB_NAME = "facesSDK";
    private static final String USERFACE_TABLE = "UserFace";
    private static final String CREATE_USERFACE_TABLE = "" +
            "CREATE TABLE IF NOT EXISTS " + USERFACE_TABLE +  "(" +
            "id INTEGER PRIMARY KEY," +
            "userId INTEGER NOT NULL," +
            "template BLOB NOT NULL" +
            ")";
    private static DatabaseConnectionService connection;
    private static SQLiteDatabase db;

    //constructor
    private DatabaseConnectionService(Context context) {
        super( context ,DB_NAME, null, DB_VERSION);
    }

    public static DatabaseConnectionService getInstance(Context context) {
        if (connection == null) {
            connection = new DatabaseConnectionService(context);
        }
        return connection;
    }



    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(CREATE_USERFACE_TABLE);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + USERFACE_TABLE );
        onCreate(db);
    }

    public synchronized long insertFaceToDB(Face face) {
        long res = -1;
        if (db.isOpen()) {
            db = connection.getWritableDatabase();
            ContentValues cv = new ContentValues();
            cv.put("userId", face.getUserId());
            cv.put("template", face.getTemplate());
            res = db.insert(USERFACE_TABLE, null, cv);
        }
        return res;
    }

    public synchronized ArrayList<Face> getFaces() {
        ArrayList<Face> list = new ArrayList<Face>();
        if (db == null) {
            db = connection.getReadableDatabase();
        }
        Cursor c = db.rawQuery("select userId, template from " + USERFACE_TABLE, null);
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
        return list;
    }

    public synchronized void openWritable() {
        if (db == null) {
            db = connection.getWritableDatabase();
        }
    }

    public void openReadable() {
        if (db == null) {
            db = connection.getReadableDatabase();
        }
    }

    @Override
    public synchronized void close() {
        db.close();
        super.close();
    }
}
