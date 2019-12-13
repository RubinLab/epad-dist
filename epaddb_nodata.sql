-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: epaddb
-- ------------------------------------------------------
-- Server version	5.1.73

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `epaddb`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `epaddb` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `epaddb`;

--
-- Table structure for table `annotations`
--

DROP TABLE IF EXISTS `annotations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `annotations` (
  `UserLoginName` varchar(255) NOT NULL,
  `PatientID` varchar(255) NOT NULL,
  `SeriesUID` varchar(255) DEFAULT NULL,
  `DSOSeriesUID` varchar(255) DEFAULT NULL,
  `StudyUID` varchar(255) DEFAULT NULL,
  `ImageUID` varchar(255) DEFAULT NULL,
  `FrameID` int(11) DEFAULT NULL,
  `AnnotationUID` varchar(255) NOT NULL,
  `ProjectUID` varchar(255) DEFAULT NULL,
  `XML` mediumtext,
  `UPDATETIME` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `DELETED` tinyint(1) DEFAULT NULL,
  `DSOFRAMENO` int(11) DEFAULT NULL,
  `TEMPLATECODE` varchar(64) DEFAULT NULL,
  `SHAREDPROJECTS` varchar(2000) DEFAULT NULL,
  `NAME` varchar(128) DEFAULT NULL,
  `AIMCOLOR` varchar(64) DEFAULT NULL,
  `is_dicomsr` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`AnnotationUID`),
  KEY `annotations_series_ind` (`SeriesUID`),
  KEY `annotations_project_ind` (`ProjectUID`),
  KEY `STUDYUID_INDEX` (`StudyUID`),
  KEY `PATIENTID_INDEX` (`PatientID`),
  KEY `USER_FOREIGN_KEY_INDEX` (`UserLoginName`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `annotations`
--

LOCK TABLES `annotations` WRITE;
/*!40000 ALTER TABLE `annotations` DISABLE KEYS */;
/*!40000 ALTER TABLE `annotations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coordination2term`
--

DROP TABLE IF EXISTS `coordination2term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coordination2term` (
  `coordination_key` mediumint(9) DEFAULT NULL,
  `term_key` mediumint(9) DEFAULT NULL,
  `position` mediumint(9) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coordination2term`
--

LOCK TABLES `coordination2term` WRITE;
/*!40000 ALTER TABLE `coordination2term` DISABLE KEYS */;
/*!40000 ALTER TABLE `coordination2term` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coordinations`
--

DROP TABLE IF EXISTS `coordinations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coordinations` (
  `coordination_key` mediumint(9) NOT NULL AUTO_INCREMENT,
  `coordination_id` varchar(60) DEFAULT NULL,
  `schema_name` varchar(60) DEFAULT NULL,
  `schema_version` varchar(60) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`coordination_key`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coordinations`
--

LOCK TABLES `coordinations` WRITE;
/*!40000 ALTER TABLE `coordinations` DISABLE KEYS */;
/*!40000 ALTER TABLE `coordinations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dbversion`
--

DROP TABLE IF EXISTS `dbversion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dbversion` (
  `version` varchar(6) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dbversion`
--

LOCK TABLES `dbversion` WRITE;
/*!40000 ALTER TABLE `dbversion` DISABLE KEYS */;
INSERT INTO `dbversion` VALUES ('4.0');
/*!40000 ALTER TABLE `dbversion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `disabled_template`
--

DROP TABLE IF EXISTS `disabled_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `disabled_template` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int(10) unsigned DEFAULT NULL,
  `templatename` varchar(128) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_disabled_template_ind` (`project_id`,`templatename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `disabled_template`
--

LOCK TABLES `disabled_template` WRITE;
/*!40000 ALTER TABLE `disabled_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `disabled_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `epad_file`
--

DROP TABLE IF EXISTS `epad_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `epad_file` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int(10) unsigned DEFAULT NULL,
  `subject_id` int(10) unsigned DEFAULT NULL,
  `study_id` int(10) unsigned DEFAULT NULL,
  `series_uid` varchar(256) DEFAULT NULL,
  `name` varchar(128) DEFAULT NULL,
  `filepath` varchar(512) DEFAULT NULL,
  `filetype` varchar(64) DEFAULT NULL,
  `mimetype` varchar(64) DEFAULT NULL,
  `description` varchar(512) DEFAULT NULL,
  `length` int(11) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `templateleveltype` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_epadfile_study` (`study_id`),
  KEY `FK_epadfile_subject` (`subject_id`),
  KEY `FK_epadfile_project` (`project_id`),
  CONSTRAINT `FK_epadfile_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `FK_epadfile_study` FOREIGN KEY (`study_id`) REFERENCES `study` (`id`),
  CONSTRAINT `FK_epadfile_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `epad_file`
--

LOCK TABLES `epad_file` WRITE;
/*!40000 ALTER TABLE `epad_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `epad_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `epad_files`
--

DROP TABLE IF EXISTS `epad_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `epad_files` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `instance_fk` int(11) DEFAULT NULL,
  `file_type` int(11) DEFAULT NULL,
  `file_path` varchar(1024) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `file_status` int(11) DEFAULT NULL,
  `err_msg` varchar(128) DEFAULT NULL,
  `file_md5` varchar(64) DEFAULT NULL,
  `last_md5_check_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`pk`),
  KEY `instance_fk` (`instance_fk`),
  KEY `epad_files_ind1` (`file_status`),
  KEY `epad_files_ind2` (`file_path`(1000))
) ENGINE=MyISAM AUTO_INCREMENT=100935 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `epad_files`
--

LOCK TABLES `epad_files` WRITE;
/*!40000 ALTER TABLE `epad_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `epad_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `epadstatistics`
--

DROP TABLE IF EXISTS `epadstatistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `epadstatistics` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `host` varchar(128) DEFAULT NULL,
  `numOfUsers` int(11) DEFAULT NULL,
  `numOfProjects` int(11) DEFAULT NULL,
  `numOfPatients` int(11) DEFAULT NULL,
  `numOfStudies` int(11) DEFAULT NULL,
  `numOfSeries` int(11) DEFAULT NULL,
  `numOfAims` int(11) DEFAULT NULL,
  `numOfDSOs` int(11) DEFAULT NULL,
  `numOfWorkLists` int(11) DEFAULT NULL,
  `numOfPacs` int(11) DEFAULT NULL,
  `numOfAutoQueries` int(11) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `numOfFiles` int(11) DEFAULT NULL,
  `numOfPlugins` int(11) DEFAULT NULL,
  `numOfTemplates` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `epadstatistics`
--

LOCK TABLES `epadstatistics` WRITE;
/*!40000 ALTER TABLE `epadstatistics` DISABLE KEYS */;
/*!40000 ALTER TABLE `epadstatistics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `epadstatistics_monthly`
--

DROP TABLE IF EXISTS `epadstatistics_monthly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `epadstatistics_monthly` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `numOfUsers` int(11) DEFAULT NULL,
  `numOfProjects` int(11) DEFAULT NULL,
  `numOfPatients` int(11) DEFAULT NULL,
  `numOfStudies` int(11) DEFAULT NULL,
  `numOfSeries` int(11) DEFAULT NULL,
  `numOfAims` int(11) DEFAULT NULL,
  `numOfDSOs` int(11) DEFAULT NULL,
  `numOfWorkLists` int(11) DEFAULT NULL,
  `numOfPacs` int(11) DEFAULT NULL,
  `numOfAutoQueries` int(11) DEFAULT NULL,
  `numOfFiles` int(11) DEFAULT NULL,
  `numOfPlugins` int(11) DEFAULT NULL,
  `numOfTemplates` int(11) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `epadstatistics_monthly`
--

LOCK TABLES `epadstatistics_monthly` WRITE;
/*!40000 ALTER TABLE `epadstatistics_monthly` DISABLE KEYS */;
/*!40000 ALTER TABLE `epadstatistics_monthly` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `epadstatistics_template`
--

DROP TABLE IF EXISTS `epadstatistics_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `epadstatistics_template` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `host` varchar(128) DEFAULT NULL,
  `templateLevelType` varchar(128) DEFAULT NULL,
  `templateName` varchar(128) DEFAULT NULL,
  `authors` varchar(128) DEFAULT NULL,
  `version` varchar(10) DEFAULT NULL,
  `templateDescription` varchar(256) DEFAULT NULL,
  `templateType` varchar(128) DEFAULT NULL,
  `templateCode` varchar(128) DEFAULT NULL,
  `numOfAims` int(11) DEFAULT NULL,
  `templateText` mediumtext,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1656 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `epadstatistics_template`
--

LOCK TABLES `epadstatistics_template` WRITE;
/*!40000 ALTER TABLE `epadstatistics_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `epadstatistics_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eventlog`
--

DROP TABLE IF EXISTS `eventlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `eventlog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `projectID` varchar(128) DEFAULT NULL,
  `subjectuid` varchar(128) DEFAULT NULL,
  `studyUID` varchar(128) DEFAULT NULL,
  `seriesUID` varchar(128) DEFAULT NULL,
  `imageUID` varchar(128) DEFAULT NULL,
  `aimID` varchar(128) DEFAULT NULL,
  `username` varchar(128) DEFAULT NULL,
  `function` varchar(128) DEFAULT NULL,
  `params` varchar(128) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `filename` varchar(250) DEFAULT NULL,
  `error` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `eventlog_ind1` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2527 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eventlog`
--

LOCK TABLES `eventlog` WRITE;
/*!40000 ALTER TABLE `eventlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `eventlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `events` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `event_status` varchar(255) DEFAULT NULL,
  `aim_uid` varchar(255) DEFAULT NULL,
  `aim_name` varchar(255) DEFAULT NULL,
  `patient_id` varchar(255) DEFAULT NULL,
  `patient_name` varchar(255) DEFAULT NULL,
  `template_id` varchar(255) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `plugin_name` varchar(255) DEFAULT NULL,
  `created_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `series_uid` varchar(128) DEFAULT NULL,
  `study_uid` varchar(128) DEFAULT NULL,
  `project_id` varchar(128) DEFAULT NULL,
  `project_name` varchar(128) DEFAULT NULL,
  `error` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`pk`),
  KEY `user_fk` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=512 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lexicon`
--

DROP TABLE IF EXISTS `lexicon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lexicon` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CODE_MEANING` varchar(255) NOT NULL,
  `CODE_VALUE` varchar(100) NOT NULL,
  `description` varchar(2000) DEFAULT NULL,
  `PARENT_ID` int(11) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `SCHEMA_DESIGNATOR` varchar(100) DEFAULT NULL,
  `SCHEMA_VERSION` varchar(8) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `synonyms` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `PRIMARY_KEY_D` (`ID`),
  UNIQUE KEY `UK_CODE_VALUE` (`CODE_VALUE`,`PARENT_ID`),
  KEY `IDX_CODE_MEANING_DESC_TDF3EEE11_082C_47CC_B9F3_8FF0BA6AA643` (`CODE_MEANING`),
  KEY `IDX_PARENT_ID_DESC_TDF3EEE11_082C_47CC_B9F3_8FF0BA6AA643` (`PARENT_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=55296 DEFAULT CHARSET=utf8;

--
-- Table structure for table `nondicom_series`
--

DROP TABLE IF EXISTS `nondicom_series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nondicom_series` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seriesuid` varchar(128) DEFAULT NULL,
  `study_id` int(10) unsigned DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `seriesdate` date DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `modality` varchar(32) DEFAULT NULL,
  `referencedseries` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_seriesuid_ind` (`seriesuid`),
  KEY `FK_projectsubjectstudy_study` (`study_id`),
  CONSTRAINT `FK_series_study` FOREIGN KEY (`study_id`) REFERENCES `study` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nondicom_series`
--

LOCK TABLES `nondicom_series` WRITE;
/*!40000 ALTER TABLE `nondicom_series` DISABLE KEYS */;
/*!40000 ALTER TABLE `nondicom_series` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pixel_values`
--

DROP TABLE IF EXISTS `pixel_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pixel_values` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `file_path` varchar(256) DEFAULT NULL,
  `image_uid` varchar(128) DEFAULT NULL,
  `frame_num` int(11) DEFAULT NULL,
  `value` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pixel_values`
--

LOCK TABLES `pixel_values` WRITE;
/*!40000 ALTER TABLE `pixel_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `pixel_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plugin`
--

DROP TABLE IF EXISTS `plugin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plugin` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `plugin_id` varchar(64) DEFAULT NULL,
  `name` varchar(128) DEFAULT NULL,
  `description` varchar(128) DEFAULT NULL,
  `javaclass` varchar(256) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `status` varchar(64) DEFAULT NULL,
  `modality` varchar(64) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `developer` varchar(128) DEFAULT NULL,
  `documentation` varchar(2000) DEFAULT NULL,
  `rateTotal` int(11) DEFAULT NULL,
  `rateCount` int(11) DEFAULT NULL,
  `processmultipleaims` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `plugin_pluginid_ind` (`plugin_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plugin`
--

LOCK TABLES `plugin` WRITE;
/*!40000 ALTER TABLE `plugin` DISABLE KEYS */;
INSERT INTO `plugin` VALUES (1,'jjv-5','jjvector','','edu.stanford.epad.plugins.jjvector.JJFeatureVectorHandler',1,NULL,NULL,'admin','2015-09-29 19:28:27','2015-09-29 19:28:27',NULL,NULL,NULL,NULL,NULL,0),(2,'lseg-1','lesionseg','','edu.stanford.epad.plugins.lesionseg.LesionSegPluginHandler',1,NULL,NULL,'admin','2015-09-29 19:28:27','2015-09-29 19:28:27',NULL,NULL,NULL,NULL,NULL,0),(3,'ts-1','tedseg','Lesion segmentation on PET images','edu.stanford.epad.plugins.tedseg.TedSegmentationHandler',1,NULL,NULL,'admin','2015-09-29 19:28:27','2016-11-22 23:14:44',NULL,'Edward Graves',NULL,0,0,0),(4,'smp-1','sampleplugin','','edu.stanford.epad.plugins.sampleplugin.SamplePluginHandler',1,NULL,NULL,'admin','2015-09-29 19:28:27','2016-04-15 18:24:50',NULL,NULL,NULL,0,0,0),(5,'rsz-1','riesz','','edu.stanford.epad.plugins.riesz.RieszPluginHandler',1,NULL,NULL,'admin','2015-09-29 19:28:27','2015-09-29 19:28:27',NULL,NULL,NULL,NULL,NULL,0),(6,'vanderbilt','vanderbilt','','edu.stanford.epad.plugins.vanderbilt.VanderbiltHandler',1,NULL,NULL,'admin','2017-11-25 08:01:31','2017-11-25 07:15:40',NULL,NULL,NULL,0,0,0);
/*!40000 ALTER TABLE `plugin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) DEFAULT NULL,
  `projectid` varchar(128) DEFAULT NULL,
  `type` varchar(32) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `defaulttemplate` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_projectid_ind` (`projectid`),
  UNIQUE KEY `project_name_ind` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project`
--

LOCK TABLES `project` WRITE;
/*!40000 ALTER TABLE `project` DISABLE KEYS */;
INSERT INTO `project` VALUES (1,'All','all','Public','Default Project','admin','2015-10-27 16:57:29','2015-03-09 21:00:21','admin',NULL),(2,'Unassigned','nonassigned','Private','Dummy project that shows patients which are not assigned to any project','admin','2015-09-29 19:29:59','2015-09-29 19:29:59',NULL,NULL);
/*!40000 ALTER TABLE `project` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_file`
--

DROP TABLE IF EXISTS `project_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_file` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int(10) unsigned DEFAULT NULL,
  `file_id` int(10) unsigned DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_file_ind` (`project_id`,`file_id`),
  KEY `FK_project_file_file` (`file_id`),
  KEY `FK_project_file_project` (`project_id`),
  CONSTRAINT `FK_project_file_file` FOREIGN KEY (`file_id`) REFERENCES `epad_file` (`id`),
  CONSTRAINT `FK_project_file_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_file`
--

LOCK TABLES `project_file` WRITE;
/*!40000 ALTER TABLE `project_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `project_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_plugin`
--

DROP TABLE IF EXISTS `project_plugin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_plugin` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int(10) unsigned DEFAULT NULL,
  `plugin_id` int(10) unsigned DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_plugin_ind` (`project_id`,`plugin_id`),
  KEY `FK_projectplugin_plugin` (`plugin_id`),
  KEY `FK_projectplugin_project` (`project_id`),
  CONSTRAINT `FK_projectplugin_plugin` FOREIGN KEY (`plugin_id`) REFERENCES `plugin` (`id`),
  CONSTRAINT `FK_projectplugin_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_plugin`
--

LOCK TABLES `project_plugin` WRITE;
/*!40000 ALTER TABLE `project_plugin` DISABLE KEYS */;
INSERT INTO `project_plugin` VALUES (1,1,1,1,NULL,'2015-09-29 19:28:27','2015-09-29 19:28:27',NULL),(2,1,2,1,NULL,'2015-09-29 19:28:27','2015-09-29 19:28:27',NULL),(3,1,3,1,NULL,'2015-09-29 19:28:27','2015-09-29 19:28:27',NULL),(4,1,4,1,NULL,'2015-09-29 19:28:27','2015-09-29 19:28:27',NULL),(5,1,5,1,NULL,'2015-09-29 19:28:27','2015-09-29 19:28:27',NULL),(7,1,6,1,NULL,'2017-11-25 08:03:30','2017-11-25 08:03:03',NULL);
/*!40000 ALTER TABLE `project_plugin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_pluginparameter`
--

DROP TABLE IF EXISTS `project_pluginparameter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_pluginparameter` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int(10) unsigned DEFAULT NULL,
  `plugin_id` int(10) unsigned DEFAULT NULL,
  `name` varchar(128) DEFAULT NULL,
  `default_value` varchar(128) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `description` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_projectpluginparameter_plugin` (`plugin_id`),
  KEY `FK_projectpluginparameter_project` (`project_id`),
  CONSTRAINT `FK_projectpluginparameter_plugin` FOREIGN KEY (`plugin_id`) REFERENCES `plugin` (`id`),
  CONSTRAINT `FK_projectpluginparameter_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_pluginparameter`
--

LOCK TABLES `project_pluginparameter` WRITE;
/*!40000 ALTER TABLE `project_pluginparameter` DISABLE KEYS */;
INSERT INTO `project_pluginparameter` VALUES (1,1,3,'MAXITER','-1','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'integer','Set to -1: run without iteration limit, nonzero: stop execution after N iterations'),(2,1,3,'MAXONLY','0','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'integer','Set to a nonzero value to limit region growing by the maximum only'),(3,1,3,'MAXTIME','-1','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'integer','Set to -1: run without time limit, nonzero: stop execution after specified time in seconds has elapsed'),(4,1,3,'MAXVAL','Undefined','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'double','For absolute region growing limits, this value specifies the region maximum'),(5,1,3,'MINONLY','1','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'integer','Set to a nonzero value to limit region growing by the minimum only'),(6,1,3,'MINVAL','Undefined','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'double','For absolute region growing limits, this value specifies the region minimum'),(7,1,3,'RANGE','Undefined','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'float-vector','A vector with N elements specifying the distance in pixels over which to search for a starting point'),(8,1,3,'REMPTS','Undefined','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'integer-vector','A vector containing array voxel indices that will be excluded during region growing'),(9,1,3,'SEARCH','0','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'integer','Set to a nonzero value to search for a local maximum to use as a start point'),(10,1,3,'SLICERANGE','10','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'integer','Set to zero: load in entire image volume at initiation, or nonzero: load in N slices as needed'),(11,1,3,'TOLERANCE','0.5','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'double','Set this value to specify relative region growing limits using the starting point intensity'),(12,1,3,'USEPTS','Undefined','admin','2016-11-22 23:14:44','2016-11-22 23:14:44',NULL,'integer-vector','A vector containing the permissible array voxel indices for inclusion during region growing');
/*!40000 ALTER TABLE `project_pluginparameter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_subject`
--

DROP TABLE IF EXISTS `project_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_subject` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int(10) unsigned DEFAULT NULL,
  `subject_id` int(10) unsigned DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_subject_ind` (`project_id`,`subject_id`),
  KEY `FK_projectsubject_subject` (`subject_id`),
  KEY `FK_projectsubject_project` (`project_id`),
  CONSTRAINT `FK_projectsubject_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `FK_projectsubject_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=243 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_subject`
--

LOCK TABLES `project_subject` WRITE;
/*!40000 ALTER TABLE `project_subject` DISABLE KEYS */;
/*!40000 ALTER TABLE `project_subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_subject_study`
--

DROP TABLE IF EXISTS `project_subject_study`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_subject_study` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `proj_subj_id` int(10) unsigned DEFAULT NULL,
  `study_id` int(10) unsigned DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_subject_study_ind` (`proj_subj_id`,`study_id`),
  KEY `FK_projectsubjectstudy_projectsubject` (`proj_subj_id`),
  KEY `FK_projectsubjectstudy_study` (`study_id`),
  CONSTRAINT `FK_projectsubjectstudy_projectsubject` FOREIGN KEY (`proj_subj_id`) REFERENCES `project_subject` (`id`),
  CONSTRAINT `FK_projectsubjectstudy_study` FOREIGN KEY (`study_id`) REFERENCES `study` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=260 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_subject_study`
--

LOCK TABLES `project_subject_study` WRITE;
/*!40000 ALTER TABLE `project_subject_study` DISABLE KEYS */;
/*!40000 ALTER TABLE `project_subject_study` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_subject_study_series_user_status`
--

DROP TABLE IF EXISTS `project_subject_study_series_user_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_subject_study_series_user_status` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int(10) unsigned DEFAULT NULL,
  `subject_id` int(10) unsigned DEFAULT NULL,
  `study_id` int(10) unsigned DEFAULT NULL,
  `series_uid` varchar(128) DEFAULT NULL,
  `user_id` int(10) unsigned DEFAULT NULL,
  `annotationStatus` int(11) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `psssustatus_user` (`project_id`,`subject_id`,`study_id`,`series_uid`,`user_id`),
  KEY `FK_psssustatus_project` (`project_id`),
  KEY `FK_psssustatus_subject` (`subject_id`),
  KEY `FK_psssustatus_study` (`study_id`),
  KEY `FK_psssustatus_user` (`user_id`),
  CONSTRAINT `FK_psssustatus_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `FK_psssustatus_study` FOREIGN KEY (`study_id`) REFERENCES `study` (`id`),
  CONSTRAINT `FK_psssustatus_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`),
  CONSTRAINT `FK_psssustatus_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_subject_study_series_user_status`
--

LOCK TABLES `project_subject_study_series_user_status` WRITE;
/*!40000 ALTER TABLE `project_subject_study_series_user_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `project_subject_study_series_user_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_subject_user`
--

DROP TABLE IF EXISTS `project_subject_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_subject_user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `proj_subj_id` int(10) unsigned DEFAULT NULL,
  `user_id` int(10) unsigned DEFAULT NULL,
  `status` varchar(64) DEFAULT NULL,
  `statustime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_subject_user_ind` (`proj_subj_id`,`user_id`),
  KEY `FK_projectsubjectuser_projectsubject` (`proj_subj_id`),
  KEY `FK_projectsubjectuser_user` (`user_id`),
  CONSTRAINT `FK_projectsubjectuser_projectsubject` FOREIGN KEY (`proj_subj_id`) REFERENCES `project_subject` (`id`),
  CONSTRAINT `FK_projectsubjectuser_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_subject_user`
--

LOCK TABLES `project_subject_user` WRITE;
/*!40000 ALTER TABLE `project_subject_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `project_subject_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_template`
--

DROP TABLE IF EXISTS `project_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_template` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int(10) unsigned DEFAULT NULL,
  `template_id` int(10) unsigned DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_project_template_ind` (`project_id`,`template_id`),
  KEY `FK_project_template_tid` (`template_id`),
  KEY `FK_project_template_pid` (`project_id`),
  CONSTRAINT `FK_project_template_pid` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `FK_project_template_tid` FOREIGN KEY (`template_id`) REFERENCES `template` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_template`
--

LOCK TABLES `project_template` WRITE;
/*!40000 ALTER TABLE `project_template` DISABLE KEYS */;
INSERT INTO `project_template` VALUES (1,1,1,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(2,1,2,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(3,1,3,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(4,1,4,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(5,1,5,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(6,1,6,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(7,1,7,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(8,1,8,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(9,1,9,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(10,1,10,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(11,1,11,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(12,1,12,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(13,1,13,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(14,1,14,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(15,1,15,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(17,1,17,1,NULL,'2016-11-22 00:14:32','2016-11-22 00:14:32',NULL),(19,1,19,1,NULL,'2017-11-25 07:17:33','2017-11-25 07:17:33',NULL);
/*!40000 ALTER TABLE `project_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_user`
--

DROP TABLE IF EXISTS `project_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int(10) unsigned DEFAULT NULL,
  `user_id` int(10) unsigned DEFAULT NULL,
  `role` varchar(64) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `defaulttemplate` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_user_ind` (`project_id`,`user_id`),
  KEY `FK_project_user_user` (`user_id`),
  KEY `FK_project_user_project` (`project_id`),
  CONSTRAINT `FK_project_user_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `FK_project_user_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_user`
--

LOCK TABLES `project_user` WRITE;
/*!40000 ALTER TABLE `project_user` DISABLE KEYS */;
INSERT INTO `project_user` VALUES (1,1,1,'Owner','admin','2015-03-09 21:00:21','2015-03-09 21:00:21',NULL,NULL),(2,2,1,'Owner','admin','2015-09-29 19:29:59','2015-09-29 19:29:59',NULL,NULL);
/*!40000 ALTER TABLE `project_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `remote_pac_query`
--

DROP TABLE IF EXISTS `remote_pac_query`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `remote_pac_query` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pacid` varchar(64) DEFAULT NULL,
  `requestor` varchar(128) DEFAULT NULL,
  `subject_id` int(10) unsigned DEFAULT NULL,
  `project_id` int(10) unsigned DEFAULT NULL,
  `modality` varchar(8) DEFAULT NULL,
  `period` varchar(8) DEFAULT NULL,
  `laststudydate` varchar(8) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `lastquerytime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `lastquerystatus` varchar(1024) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `remotepacquery_pacid_subject` (`pacid`,`subject_id`),
  KEY `FK_query_project` (`project_id`),
  KEY `FK_query_subject` (`subject_id`),
  CONSTRAINT `FK_query_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `FK_query_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `remote_pac_query`
--

LOCK TABLES `remote_pac_query` WRITE;
/*!40000 ALTER TABLE `remote_pac_query` DISABLE KEYS */;
/*!40000 ALTER TABLE `remote_pac_query` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviewer`
--

DROP TABLE IF EXISTS `reviewer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reviewer` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reviewer` varchar(128) DEFAULT NULL,
  `reviewee` varchar(128) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_reviewer_ind` (`reviewer`,`reviewee`),
  KEY `FK_reviewer_user` (`reviewer`),
  KEY `FK_reviewee_user` (`reviewee`),
  CONSTRAINT `FK_reviewee_user` FOREIGN KEY (`reviewee`) REFERENCES `user` (`username`),
  CONSTRAINT `FK_reviewer_user` FOREIGN KEY (`reviewer`) REFERENCES `user` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviewer`
--

LOCK TABLES `reviewer` WRITE;
/*!40000 ALTER TABLE `reviewer` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviewer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `series_status`
--

DROP TABLE IF EXISTS `series_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `series_status` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `series_iuid` varchar(128) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `created_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `default_tags` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`pk`),
  KEY `series_status_ind` (`series_iuid`)
) ENGINE=MyISAM AUTO_INCREMENT=4292 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `series_status`
--

LOCK TABLES `series_status` WRITE;
/*!40000 ALTER TABLE `series_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `series_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `study`
--

DROP TABLE IF EXISTS `study`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `study` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `studyuid` varchar(128) DEFAULT NULL,
  `studydate` date DEFAULT NULL,
  `subject_id` int(10) unsigned DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `study_studyuid_ind` (`studyuid`),
  KEY `FK_study_subject` (`subject_id`),
  CONSTRAINT `FK_study_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study`
--

LOCK TABLES `study` WRITE;
/*!40000 ALTER TABLE `study` DISABLE KEYS */;
/*!40000 ALTER TABLE `study` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subject`
--

DROP TABLE IF EXISTS `subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subject` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `subjectuid` varchar(128) DEFAULT NULL,
  `name` varchar(256) DEFAULT NULL,
  `gender` varchar(16) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `displayuid` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subject_subjectuid_ind` (`subjectuid`)
) ENGINE=InnoDB AUTO_INCREMENT=154 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subject`
--

LOCK TABLES `subject` WRITE;
/*!40000 ALTER TABLE `subject` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `template`
--

DROP TABLE IF EXISTS `template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `templateLevelType` varchar(128) DEFAULT NULL,
  `templateUID` varchar(128) DEFAULT NULL,
  `templateName` varchar(128) DEFAULT NULL,
  `authors` varchar(128) DEFAULT NULL,
  `version` varchar(10) DEFAULT NULL,
  `templateCreationDate` timestamp NULL DEFAULT NULL,
  `templateDescription` varchar(256) DEFAULT NULL,
  `codingSchemeVersion` varchar(10) DEFAULT NULL,
  `templateType` varchar(128) DEFAULT NULL,
  `templateCode` varchar(128) DEFAULT NULL,
  `codingSchemeDesignator` varchar(128) DEFAULT NULL,
  `modality` varchar(12) DEFAULT NULL,
  `file_id` int(10) unsigned DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `templateCode` (`templateCode`),
  KEY `FK_template_file` (`file_id`),
  CONSTRAINT `FK_template_file` FOREIGN KEY (`file_id`) REFERENCES `epad_file` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `template`
--

LOCK TABLES `template` WRITE;
/*!40000 ALTER TABLE `template` DISABLE KEYS */;
/*!40000 ALTER TABLE `template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terms`
--

DROP TABLE IF EXISTS `terms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terms` (
  `term_key` mediumint(9) NOT NULL AUTO_INCREMENT,
  `term_id` varchar(60) DEFAULT NULL,
  `schema_name` varchar(60) DEFAULT NULL,
  `schema_version` varchar(60) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`term_key`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terms`
--

LOCK TABLES `terms` WRITE;
/*!40000 ALTER TABLE `terms` DISABLE KEYS */;
INSERT INTO `terms` VALUES (1,'RID3829','RadLex3.10_NS','','scar'),(2,'RID46020','RadLex.3.10','','bronchovascular bundle'),(3,'RID5702','RadLex3.10_NS','','focal'),(4,'RID5914','RadLex3.10_NS','','thickened'),(5,'RID3820','RadLex3.10_NS','','fibrosis'),(6,'RID46011','RadLex.3.10','','partially solid'),(7,'RID46011','RadLex.3.10','','partially solid'),(8,'RID5701','RadLex3.10_NS','','diffuse'),(9,'LT2','LungTemplate','','Solid lessOrEqual 5mm'),(10,'LT3','LungTemplate','','Solid greaterThan 5mm');
/*!40000 ALTER TABLE `terms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `upload_comment`
--

DROP TABLE IF EXISTS `upload_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `upload_comment` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `login_name` varchar(128) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `study_uid` varchar(255) DEFAULT NULL,
  `created_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`pk`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `upload_comment`
--

LOCK TABLES `upload_comment` WRITE;
/*!40000 ALTER TABLE `upload_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `upload_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(128) DEFAULT NULL,
  `firstname` varchar(256) DEFAULT NULL,
  `lastname` varchar(256) DEFAULT NULL,
  `email` varchar(256) DEFAULT NULL,
  `password` varchar(256) DEFAULT NULL,
  `permissions` varchar(2000) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `admin` tinyint(1) DEFAULT NULL,
  `passwordexpired` tinyint(1) DEFAULT NULL,
  `passwordupdate` date DEFAULT NULL,
  `lastlogin` timestamp NULL DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `colorpreference` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_username_ind` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','Epad','Admin','epad@epad-build.stanford.edu','$2a$10$5k1FZJvBatiydTBCPWKkaOMEJIl5z1MOImHHTK0zxNwnqDaxqwYze','',1,1,0,'2015-03-09','2015-06-23 21:23:16','admin','2015-03-09 21:00:13','2015-03-09 21:00:20','admin',NULL),(2,'guest','XNAT','Guest','epad@epad-build.stanford.edu','$2a$10$muFZcWbJdi.Z8WBTWJ3/setviKawaVGRlrmzBI5sfI9YcS49PLdDu','CreateProject',1,0,0,NULL,'2015-06-23 21:23:16','admin','2015-03-09 21:00:20','2015-03-09 21:00:20',NULL,NULL);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_flaggedimage`
--

DROP TABLE IF EXISTS `user_flaggedimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_flaggedimage` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(128) DEFAULT NULL,
  `image_uid` varchar(128) DEFAULT NULL,
  `project_id` varchar(128) DEFAULT NULL,
  `subject_id` varchar(128) DEFAULT NULL,
  `study_id` varchar(128) DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_flaggedimage`
--

LOCK TABLES `user_flaggedimage` WRITE;
/*!40000 ALTER TABLE `user_flaggedimage` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_flaggedimage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `worklist`
--

DROP TABLE IF EXISTS `worklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `worklist` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `worklistid` varchar(128) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `user_id` int(10) unsigned DEFAULT NULL,
  `status` varchar(256) DEFAULT NULL,
  `startdate` date DEFAULT NULL,
  `completedate` date DEFAULT NULL,
  `duedate` date DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  `name` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `worklist_ind` (`worklistid`),
  KEY `FK_worklist_user` (`user_id`),
  CONSTRAINT `FK_worklist_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `worklist`
--

LOCK TABLES `worklist` WRITE;
/*!40000 ALTER TABLE `worklist` DISABLE KEYS */;
/*!40000 ALTER TABLE `worklist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `worklist_study`
--

DROP TABLE IF EXISTS `worklist_study`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `worklist_study` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `worklist_id` int(10) unsigned DEFAULT NULL,
  `study_id` int(10) unsigned DEFAULT NULL,
  `project_id` int(10) unsigned DEFAULT NULL,
  `sortorder` int(10) unsigned DEFAULT NULL,
  `status` varchar(256) DEFAULT NULL,
  `startdate` date DEFAULT NULL,
  `completedate` date DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `worklist_study_ind` (`worklist_id`,`study_id`,`project_id`),
  KEY `FK_workliststudy_study` (`study_id`),
  KEY `FK_workliststudy_worklist` (`worklist_id`),
  KEY `FK_workliststudy_project` (`project_id`),
  CONSTRAINT `FK_workliststudy_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `FK_workliststudy_study` FOREIGN KEY (`study_id`) REFERENCES `study` (`id`),
  CONSTRAINT `FK_workliststudy_worklist` FOREIGN KEY (`worklist_id`) REFERENCES `worklist` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `worklist_study`
--

LOCK TABLES `worklist_study` WRITE;
/*!40000 ALTER TABLE `worklist_study` DISABLE KEYS */;
/*!40000 ALTER TABLE `worklist_study` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `worklist_subject`
--

DROP TABLE IF EXISTS `worklist_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `worklist_subject` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `worklist_id` int(10) unsigned DEFAULT NULL,
  `subject_id` int(10) unsigned DEFAULT NULL,
  `project_id` int(10) unsigned DEFAULT NULL,
  `sortorder` int(10) unsigned DEFAULT NULL,
  `status` varchar(256) DEFAULT NULL,
  `startdate` date DEFAULT NULL,
  `completedate` date DEFAULT NULL,
  `creator` varchar(128) DEFAULT NULL,
  `createdtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `worklist_subject_ind` (`worklist_id`,`subject_id`,`project_id`),
  KEY `FK_worklistsubject_subject` (`subject_id`),
  KEY `FK_worklistsubject_worklist` (`worklist_id`),
  KEY `FK_worklistsubject_project` (`project_id`),
  CONSTRAINT `FK_worklistsubject_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `FK_worklistsubject_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`),
  CONSTRAINT `FK_worklistsubject_worklist` FOREIGN KEY (`worklist_id`) REFERENCES `worklist` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `worklist_subject`
--

LOCK TABLES `worklist_subject` WRITE;
/*!40000 ALTER TABLE `worklist_subject` DISABLE KEYS */;
/*!40000 ALTER TABLE `worklist_subject` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-07-15 13:44:35
