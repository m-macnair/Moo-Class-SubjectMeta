-- phpMyAdmin SQL Dump
-- version 4.8.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 24, 2020 at 12:52 PM
-- Server version: 10.0.26-MariaDB
-- PHP Version: 5.6.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `subject_metadata`
--

-- --------------------------------------------------------

--
-- Table structure for table `subject_table`
--

CREATE TABLE `subject_table` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8_bin NOT NULL,
  `user` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `tag_alias`
--

CREATE TABLE `tag_alias` (
  `id` int(10) UNSIGNED NOT NULL,
  `source_tag_id` int(10) UNSIGNED NOT NULL,
  `target_tag_id` int(10) UNSIGNED NOT NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `tag_cloud`
--

CREATE TABLE `tag_cloud` (
  `id` int(10) UNSIGNED NOT NULL,
  `subject_id` int(10) UNSIGNED NOT NULL,
  `tag_id` int(10) UNSIGNED NOT NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `tag_def`
--

CREATE TABLE `tag_def` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8_bin NOT NULL,
  `subjects` int(10) UNSIGNED NOT NULL,
  `user` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `tag_implies`
--

CREATE TABLE `tag_implies` (
  `id` int(10) UNSIGNED NOT NULL,
  `source_tag_id` int(10) UNSIGNED NOT NULL,
  `target_tag_id` int(10) UNSIGNED NOT NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `subject_table`
--
ALTER TABLE `subject_table`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `user` (`user`);

--
-- Indexes for table `tag_alias`
--
ALTER TABLE `tag_alias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `source_tag_id` (`source_tag_id`),
  ADD KEY `target_tag_id` (`target_tag_id`),
  ADD KEY `stamp` (`stamp`),
  ADD KEY `user` (`user`);

--
-- Indexes for table `tag_cloud`
--
ALTER TABLE `tag_cloud`
  ADD PRIMARY KEY (`id`),
  ADD KEY `subject_id` (`subject_id`),
  ADD KEY `tag_id` (`tag_id`),
  ADD KEY `stamp` (`stamp`),
  ADD KEY `user` (`user`);

--
-- Indexes for table `tag_def`
--
ALTER TABLE `tag_def`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `subjects` (`subjects`),
  ADD KEY `user` (`user`);

--
-- Indexes for table `tag_implies`
--
ALTER TABLE `tag_implies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `source_tag_id` (`source_tag_id`),
  ADD KEY `target_tag_id` (`target_tag_id`),
  ADD KEY `stamp` (`stamp`),
  ADD KEY `user` (`user`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `subject_table`
--
ALTER TABLE `subject_table`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tag_alias`
--
ALTER TABLE `tag_alias`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tag_cloud`
--
ALTER TABLE `tag_cloud`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tag_def`
--
ALTER TABLE `tag_def`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tag_implies`
--
ALTER TABLE `tag_implies`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
