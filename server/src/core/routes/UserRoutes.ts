import { IRouter, Router } from 'express';

import UserController from '@core/controllers/UserController';

class UserRoutes {
  public router: IRouter;

  constructor() {
    this.router = Router();

    this.router.post('/api/v1/signup', UserController.signup);
    this.router.post('/api/v1/login', UserController.login);

    this.router.get('/api/v1/tasks', UserController.protect, UserController.getTasks);
    this.router.post('/api/v1/create-task', UserController.protect, UserController.createTask);
    this.router.patch('/api/v1/update-task/:id', UserController.protect, UserController.updateTask);
    this.router.patch(
      '/api/v1/update-completed/:id',
      UserController.protect,
      UserController.updateTaskCompleted
    );
    this.router.delete('/api/v1/task/:id', UserController.protect, UserController.deleteTask);
  }
}

export default UserRoutes;
