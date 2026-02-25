import express, { Request, Response } from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import 'dotenv/config';
import { TransactionService } from './services/transaction-service';

const transactionService = new TransactionService();

const app = express();
app.use(cors());
app.use(bodyParser.json());

const port = 3000;

// GET alle Transaktionen
app.get('/transactions', (req: Request, res: Response) => {
    res.send(transactionService.getAllTransactions());
});

// GET einzelne Transaktion
app.get('/transactions/:id', (req: Request, res: Response) => {
    const transaction = transactionService.getTransactionById(req.params.id as string);
    if (!transaction) {
        res.status(404).send({ error: 'Transaktion nicht gefunden' });
        return;
    }
    res.send(transaction);
});

// POST neue Transaktion
app.post('/transactions', (req: Request, res: Response) => {
    const transaction = transactionService.addTransaction(req.body);
    res.status(201).send(transaction);
});

// PUT Transaktion aktualisieren
app.put('/transactions/:id', (req: Request, res: Response) => {
    const transaction = transactionService.updateTransaction(req.params.id as string, req.body);
    if (!transaction) {
        res.status(404).send({ error: 'Transaktion nicht gefunden' });
        return;
    }
    res.send(transaction);
});

// DELETE Transaktion löschen
app.delete('/transactions/:id', (req: Request, res: Response) => {
    const transaction = transactionService.deleteTransaction(req.params.id as string);
    if (!transaction) {
        res.status(404).send({ error: 'Transaktion nicht gefunden' });
        return;
    }
    res.send(transaction);
});

app.listen(port, () => {
    console.log(`FinanceTracker API gestartet auf Port ${port}`);
});
