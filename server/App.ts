import express from 'express';
import cors from 'cors';
import { config } from 'dotenv';
import * as path from 'path';
import mysql2 from 'mysql2/promise';

import UserRoutes from '@core/routes/UserRoutes';

class App {
  private app: express.Application;
  private UserRouter = new UserRoutes().router;

  constructor(port: number) {
    this.app = express();
    this.configurations(port);
    this.routes();
  }

  private configurations(port: number): void {
    if (process.argv[2] === 'cloud') {
      config({ path: path.resolve(`${process.cwd()}/env`, '.env') });
    } else {
      config({ path: path.resolve(`${process.cwd()}/env`, 'local.env') });
    }

    this.app.listen(port);
    this.app.use(cors());
    this.app.use(express.json());
  }

  private routes(): void {
    this.app.use('/', this.UserRouter);
  }

  public static createConnection(): mysql2.Pool {
    const pool = mysql2.createPool({
      host: process.env.MYSQL_HOST,
      user: process.env.MYSQL_USER,
      password: process.env.MYSQL_PASSWORD,
      database: process.env.MYSQL_DATABASE,
    });

    pool.on('connection', () => {
      console.log('conectado');
    });

    return pool;
  }

  private env(): void {
    console.log(process.env.MYSQL_HOST);
    console.log(process.env.MYSQL_USER);
    console.log(process.env.MYSQL_PASSWORD);
    console.log(process.env.MYSQL_DATABASE);
  }
}

export default App;

new App(5050);
