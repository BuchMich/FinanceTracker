import { Transaction } from '../models/transaction';
import { dbAll, dbGet, dbRun } from '../database';

export class TransactionService {

    async getAllTransactions(): Promise<Transaction[]> {
        return dbAll<Transaction>('SELECT * FROM transactions ORDER BY date DESC');
    }

    async getTransactionById(id: string): Promise<Transaction | undefined> {
        return dbGet<Transaction>('SELECT * FROM transactions WHERE id = ?', [id]);
    }

    async addTransaction(data: Omit<Transaction, 'id'>): Promise<Transaction> {
        const result = await dbRun(
            'INSERT INTO transactions (title, amount, type, category, date) VALUES (?, ?, ?, ?, ?)',
            [data.title, data.amount, data.type, data.category, data.date]
        );
        return (await this.getTransactionById(result.lastID.toString()))!;
    }

    async updateTransaction(id: string, data: Partial<Omit<Transaction, 'id'>>): Promise<Transaction | undefined> {
        const existing = await this.getTransactionById(id);
        if (!existing) return undefined;

        const updated = { ...existing, ...data };
        await dbRun(
            'UPDATE transactions SET title = ?, amount = ?, type = ?, category = ?, date = ? WHERE id = ?',
            [updated.title, updated.amount, updated.type, updated.category, updated.date, id]
        );
        return this.getTransactionById(id);
    }

    async deleteTransaction(id: string): Promise<Transaction | undefined> {
        const existing = await this.getTransactionById(id);
        if (!existing) return undefined;

        await dbRun('DELETE FROM transactions WHERE id = ?', [id]);
        return existing;
    }
}
