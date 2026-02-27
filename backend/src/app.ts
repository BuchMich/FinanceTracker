import express, { Request, Response } from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import 'dotenv/config';
import { initDatabase } from './database';
import { TransactionService } from './services/transaction-service';
import { SavingsGoalService } from './services/savings-goal-service';

const transactionService = new TransactionService();
const savingsGoalService = new SavingsGoalService();

const app = express();
app.use(cors());
app.use(bodyParser.json());

const port = 3000;

// ==================== TRANSACTIONS ====================

// GET alle Transaktionen
app.get('/transactions', async (req: Request, res: Response) => {
    res.send(await transactionService.getAllTransactions());
});

// GET einzelne Transaktion
app.get('/transactions/:id', async (req: Request, res: Response) => {
    const transaction = await transactionService.getTransactionById(req.params.id as string);
    if (!transaction) {
        res.status(404).send({ error: 'Transaktion nicht gefunden' });
        return;
    }
    res.send(transaction);
});

// POST neue Transaktion
app.post('/transactions', async (req: Request, res: Response) => {
    const transaction = await transactionService.addTransaction(req.body);
    res.status(201).send(transaction);
});

// PUT Transaktion aktualisieren
app.put('/transactions/:id', async (req: Request, res: Response) => {
    const transaction = await transactionService.updateTransaction(req.params.id as string, req.body);
    if (!transaction) {
        res.status(404).send({ error: 'Transaktion nicht gefunden' });
        return;
    }
    res.send(transaction);
});

// DELETE Transaktion löschen
app.delete('/transactions/:id', async (req: Request, res: Response) => {
    const transaction = await transactionService.deleteTransaction(req.params.id as string);
    if (!transaction) {
        res.status(404).send({ error: 'Transaktion nicht gefunden' });
        return;
    }
    res.send(transaction);
});

// ==================== SAVINGS GOALS ====================

// GET alle Sparziele
app.get('/savings-goals', async (req: Request, res: Response) => {
    res.send(await savingsGoalService.getAllGoals());
});

// GET einzelnes Sparziel
app.get('/savings-goals/:id', async (req: Request, res: Response) => {
    const goal = await savingsGoalService.getGoalById(req.params.id as string);
    if (!goal) {
        res.status(404).send({ error: 'Sparziel nicht gefunden' });
        return;
    }
    res.send(goal);
});

// POST neues Sparziel
app.post('/savings-goals', async (req: Request, res: Response) => {
    const goal = await savingsGoalService.addGoal(req.body);
    res.status(201).send(goal);
});

// PUT Sparziel aktualisieren
app.put('/savings-goals/:id', async (req: Request, res: Response) => {
    const goal = await savingsGoalService.updateGoal(req.params.id as string, req.body);
    if (!goal) {
        res.status(404).send({ error: 'Sparziel nicht gefunden' });
        return;
    }
    res.send(goal);
});

// DELETE Sparziel löschen
app.delete('/savings-goals/:id', async (req: Request, res: Response) => {
    const goal = await savingsGoalService.deleteGoal(req.params.id as string);
    if (!goal) {
        res.status(404).send({ error: 'Sparziel nicht gefunden' });
        return;
    }
    res.send(goal);
});

// Datenbank initialisieren, dann Server starten
initDatabase().then(() => {
    app.listen(port, () => {
        console.log(`FinanceTracker API gestartet auf Port ${port}`);
    });
}).catch((err) => {
    console.error('Fehler beim Initialisieren der Datenbank:', err);
});
