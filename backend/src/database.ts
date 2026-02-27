import sqlite3 from 'sqlite3';
import path from 'path';

const dbPath = path.join(__dirname, '..', 'database.db');
const db = new sqlite3.Database(dbPath);

// Hilfsfunktionen um Callbacks in Promises umzuwandeln
export function dbAll<T = any>(sql: string, params: any[] = []): Promise<T[]> {
    return new Promise((resolve, reject) => {
        db.all(sql, params, (err, rows) => {
            if (err) reject(err);
            else resolve(rows as T[]);
        });
    });
}

export function dbGet<T = any>(sql: string, params: any[] = []): Promise<T | undefined> {
    return new Promise((resolve, reject) => {
        db.get(sql, params, (err, row) => {
            if (err) reject(err);
            else resolve(row as T | undefined);
        });
    });
}

export function dbRun(sql: string, params: any[] = []): Promise<sqlite3.RunResult> {
    return new Promise((resolve, reject) => {
        db.run(sql, params, function (err) {
            if (err) reject(err);
            else resolve(this);
        });
    });
}

// Datenbank initialisieren
export async function initDatabase(): Promise<void> {
    await dbRun(`
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
            category TEXT NOT NULL,
            date TEXT NOT NULL
        )
    `);

    await dbRun(`
        CREATE TABLE IF NOT EXISTS savings_goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            target_amount REAL NOT NULL,
            current_amount REAL DEFAULT 0
        )
    `);

    // Seed-Daten einfügen, falls die Tabelle leer ist
    const count = await dbGet<{ count: number }>('SELECT COUNT(*) as count FROM transactions');
    if (count && count.count === 0) {
        const seedTransactions = [
            { title: 'Supermarkt', amount: 54.30, type: 'expense', category: 'Essen', date: '2026-01-30' },
            { title: 'Gehalt', amount: 2100.00, type: 'income', category: 'Einkommen', date: '2026-01-28' },
            { title: 'Miete', amount: 750.00, type: 'expense', category: 'Wohnen', date: '2026-02-01' },
            { title: 'Streaming', amount: 14.99, type: 'expense', category: 'Freizeit', date: '2026-01-25' },
            { title: 'Freelance', amount: 450.00, type: 'income', category: 'Einkommen', date: '2026-01-20' },
        ];

        for (const t of seedTransactions) {
            await dbRun(
                'INSERT INTO transactions (title, amount, type, category, date) VALUES (?, ?, ?, ?, ?)',
                [t.title, t.amount, t.type, t.category, t.date]
            );
        }
    }
}

export default db;
