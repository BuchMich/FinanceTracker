import { SavingsGoal } from '../models/savings-goal';
import { dbAll, dbGet, dbRun } from '../database';

export class SavingsGoalService {

    async getAllGoals(): Promise<SavingsGoal[]> {
        return dbAll<SavingsGoal>('SELECT * FROM savings_goals');
    }

    async getGoalById(id: string): Promise<SavingsGoal | undefined> {
        return dbGet<SavingsGoal>('SELECT * FROM savings_goals WHERE id = ?', [id]);
    }

    async addGoal(data: Omit<SavingsGoal, 'id'>): Promise<SavingsGoal> {
        const result = await dbRun(
            'INSERT INTO savings_goals (title, target_amount, current_amount) VALUES (?, ?, ?)',
            [data.title, data.target_amount, data.current_amount || 0]
        );
        return (await this.getGoalById(result.lastID.toString()))!;
    }

    async updateGoal(id: string, data: Partial<Omit<SavingsGoal, 'id'>>): Promise<SavingsGoal | undefined> {
        const existing = await this.getGoalById(id);
        if (!existing) return undefined;

        const updated = { ...existing, ...data };
        await dbRun(
            'UPDATE savings_goals SET title = ?, target_amount = ?, current_amount = ? WHERE id = ?',
            [updated.title, updated.target_amount, updated.current_amount, id]
        );
        return this.getGoalById(id);
    }

    async deleteGoal(id: string): Promise<SavingsGoal | undefined> {
        const existing = await this.getGoalById(id);
        if (!existing) return undefined;

        await dbRun('DELETE FROM savings_goals WHERE id = ?', [id]);
        return existing;
    }
}
