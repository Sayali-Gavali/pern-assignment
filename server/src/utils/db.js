import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
dotenv.config();
export const pool = mysql.createPool({host:process.env.DB_HOST||'localhost',port:Number(process.env.DB_PORT||3306),user:process.env.DB_USER||'root',password:process.env.DB_PASSWORD||'',database:process.env.DB_NAME||'pern_erp',waitForConnections:true,connectionLimit:10,decimalNumbers:true});
export async function withTransaction(fn){const conn=await pool.getConnection();try{await conn.beginTransaction();const result=await fn(conn);await conn.commit();return result;}catch(e){await conn.rollback();throw e;}finally{conn.release();}}
export async function query(sql,params=[]){const [rows]=await pool.execute(sql,params);return rows;}
export function one(rows){return rows?.[0]||null;}
export function makeId(){return crypto.randomUUID();}
import crypto from 'node:crypto';
