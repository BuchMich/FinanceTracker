import { Transaction } from '../models/transaction';
import { v4 as uuidv4 } from 'uuid';

export class TransactionService {
    private transactions: Transaction[] = [
        {
            id: uuidv4(),
            title: 'Supermarkt',
            amount: -54.30,
            date: '2026-01-30',
            category: 'Essen',
        },
        {
            id: uuidv4(),
            title: 'Gehalt',
            amount: 2100.00,
            date: '2026-01-28',
            category: 'Einkommen',
        },
        {
            id: uuidv4(),
            title: 'Miete',
            amount: -750.00,
            date: '2026-02-01',
            category: 'Wohnen',
        },
        {
            id: uuidv4(),
            title: 'Streaming',
            amount: -14.99,
            date: '2026-01-25',
            category: 'Freizeit',
        },
        {
            id: uuidv4(),
            title: 'Freelance',
            amount: 450.00,
            date: '2026-01-20',
            category: 'Einkommen',
        },
    ];

    getAllTransactions(): Transaction[] {
        return this.transactions;
    }

    getTransactionById(id: string): Transaction | undefined {
        return this.transactions.find((t) => t.id === id);
    }

    addTransaction(data: Omit<Transaction, 'id'>): Transaction {
        const transaction: Transaction = { id: uuidv4(), ...data };
        this.transactions.push(transaction);
        return transaction;
    }

    updateTransaction(id: string, data: Partial<Omit<Transaction, 'id'>>): Transaction | undefined {
        const index = this.transactions.findIndex((t) => t.id === id);
        if (index === -1) return undefined;
        this.transactions[index] = { ...this.transactions[index], ...data };
        return this.transactions[index];
    }

    deleteTransaction(id: string): Transaction | undefined {
        const index = this.transactions.findIndex((t) => t.id === id);
        if (index === -1) return undefined;
        const [removed] = this.transactions.splice(index, 1);
        return removed;
    }
}
