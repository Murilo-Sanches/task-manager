/* eslint-disable @typescript-eslint/no-empty-function */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unused-vars */

import { Request, Response, NextFunction } from 'express';
import * as bcrypt from 'bcrypt';
import { ResultSetHeader, RowDataPacket } from 'mysql2';

import App from 'App';

type Empty = Record<string, never>;

// + HTTP Status Code
// * O status HTTP "201 Created" é utilizado como resposta de sucesso, indica que a requisição foi bem sucedida e que um novo recurso foi criado.
// * O status de resposta 409 Conflict indica que a solicitação atual conflitou com o recurso que está no servidor.
// * O código de status de resposta HTTP 400 Bad Request indica que o servidor não pode ou não irá processar a requisição devido a alguma coisa que foi entendida como um erro do cliente
// * O código de resposta de status de erro do cliente HTTP 403 Forbidden indica que o servidor entendeu o pedido, mas se recusa a autorizá-lo.
// * O código HTTP 200 OK é a resposta de status de sucesso que indica que a requisição foi bem sucedida. Uma resposta 200 é cacheável por padrão.

class UserController {
  static async allUsers(req: Request, res: Response, next: NextFunction) {
    const [rows] = await App.createConnection().query('SELECT * FROM users');
    console.log(rows);
  }

  static async signup(
    req: Request<Empty, Empty, { email: string; username: string; password: string }>,
    res: Response
  ) {
    try {
      if (!req.body.email || !req.body.password || !req.body.username) {
        return res.status(400).json({
          status: 'fail',
          message: 'Campos obrigatórios em falta',
        });
      }

      const user = await App.createConnection().execute(
        `
        INSERT INTO
        users (email, username, password)
        VALUES (?,?,?)
      `,
        [req.body.email, req.body.username, await bcrypt.hash(req.body.password, 10)]
      );

      return res.status(201).json({
        status: 'success',
        message: 'Conta criada com sucesso',
        data: {
          id: (user[0] as ResultSetHeader).insertId,
        },
      });
    } catch (err) {
      if (((err as any).sqlMessage as string).startsWith('Duplicate')) {
        return res.status(409).json({ status: 'fail', message: 'Esse email já está em uso' });
      }
    }
  }

  static async login(
    req: Request<Empty, Empty, { email: string; password: string }>,
    res: Response
  ) {
    try {
      if (!req.body.email || !req.body.password) {
        return res.status(400).json({
          status: 'fail',
          message: 'Campos obrigatórios faltando',
        });
      }

      const rows = await App.createConnection().execute(
        `
        SELECT password, username, userId
        FROM users 
        WHERE email = ?
    `,
        [req.body.email]
      );

      if (
        (rows[0] as RowDataPacket[]).length === 0 ||
        !(await bcrypt.compare(
          req.body.password,
          ((rows[0] as RowDataPacket[])[0] as { password: string }).password
        ))
      ) {
        return res.status(403).json({ status: 'fail', message: 'Email ou Senha incorretos' });
      }

      return res.status(200).json({
        status: 'success',
        message: 'Logado com sucesso',
        data: {
          username: ((rows[0] as RowDataPacket[])[0] as { username: string }).username,
          id: ((rows[0] as RowDataPacket[])[0] as { userId: string }).userId,
        },
      });
    } catch (err) {
      console.log(err);
    }
  }

  public static async getTasks(req: Request<Empty, Empty, { id: string }>, res: Response) {
    const tasks = await App.createConnection().execute(
      `
      SELECT taskId, body, completed
      FROM tasks
      WHERE userId=?
      LIMIT 25;
    `,
      [req.headers.authorization]
    );

    return res.status(200).json({
      status: 'success',
      message: 'Todas as tasks do usuário',
      data: {
        tasks: tasks[0],
      },
    });
  }

  public static async createTask(
    req: Request<Empty, Empty, { email: string; id: string; body: string; completed: string }>,
    res: Response
  ) {
    try {
      const task = await App.createConnection().execute(
        `
      INSERT INTO tasks
      (body, completed, userId)
      VALUES(?,?,?)
    `,
        [req.body.body, req.body.completed, req.headers.authorization]
      );

      return res.status(201).json({
        status: 'success',
        message: 'Task criada',
        data: {
          taskId: (task[0] as ResultSetHeader).insertId,
        },
      });
    } catch (err) {
      console.log(err);
    }
  }

  public static async updateTask(
    req: Request<Empty, Empty, { body: string; completed: string; id: string; email: string }>,
    res: Response
  ) {
    try {
      await App.createConnection().execute(
        `
        UPDATE tasks 
        SET body=?
        WHERE taskId=? AND userId=? 
      `,
        [req.body.body, req.params.id, req.headers.authorization]
      );

      return res.status(201).json({
        status: 'success',
        message: 'Task atualizada com sucesso',
      });
    } catch (err) {
      console.log(err);
    }
  }

  public static async updateTaskCompleted(
    req: Request<Empty, Empty, { body: string; completed: string; id: string; email: string }>,
    res: Response
  ) {
    try {
      await App.createConnection().execute(
        `
        UPDATE tasks 
        SET completed=?
        WHERE taskId=? AND userId=? 
      `,
        [req.body.completed, req.params.id, req.headers.authorization]
      );

      return res.status(201).json({
        status: 'success',
        message: 'Task atualizada com sucesso',
      });
    } catch (err) {
      console.log(err);
    }
  }

  public static async deleteTask(req: Request<Empty, Empty, { id: string }>, res: Response) {
    try {
      if (!req.headers.authorization || !req.params.id) {
        return;
      }

      await App.createConnection().execute(
        `
        DELETE FROM tasks
        WHERE userId=? AND taskId=?
      `,
        [req.headers.authorization, req.params.id]
      );

      return res.status(200).json({
        status: 'success',
        message: 'Task excluida',
      });
    } catch (err) {
      console.log(err);
    }
  }

  public static async protect(
    req: Request<Empty, Empty, { id: string; email: string }>,
    res: Response,
    next: NextFunction
  ) {
    if (req.headers.authorization ?? (req.body.id || req.body.email)) {
      return next();
    }

    return res.status(500).json({
      status: 'fail',
      message: 'Alguma coisa deu errado, por favor tente logar novamente',
    });
  }
}

export default UserController;
