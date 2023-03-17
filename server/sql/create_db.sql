CREATE TABLE `tasks` (
  `taskId` int(11) NOT NULL,
  `body` varchar(255) NOT NULL,
  `completed` tinyint(1) NOT NULL DEFAULT 0,
  `userId` int(11) DEFAULT NULL
);

CREATE TABLE `users` (
  `userId` int(11) NOT NULL,
  `email` varchar(99) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(99) NOT NULL
);

ALTER TABLE `tasks`
  ADD PRIMARY KEY (`taskId`),
  ADD KEY `fk_user` (`userId`);

ALTER TABLE `users`
  ADD PRIMARY KEY (`userId`),
  ADD UNIQUE KEY `email` (`email`);

ALTER TABLE `tasks`
  MODIFY `taskId` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `users`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `tasks`
  ADD CONSTRAINT `fk_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`);