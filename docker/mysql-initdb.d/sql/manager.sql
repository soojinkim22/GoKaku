-- -----------------------------------------------------
-- Type      : Table
-- database  : manager
-- name      : M_User
-- version   : 0.1 @2017/09/26
-- -----------------------------------------------------
DROP TABLE IF EXISTS `manager`.`M_User` ;

CREATE TABLE IF NOT EXISTS `manager`.`M_User` (
  `nUserID` MEDIUMINT NOT NULL AUTO_INCREMENT COMMENT 'ユーザーID',
  `nCorpID` SMALLINT NOT NULL COMMENT '企業ID',
  `vcLogin` VARCHAR(64) NOT NULL COMMENT 'ログイン文字列',
  `vcPassword` VARCHAR(64) NULL COMMENT 'パスワード文字列（MD5ハッシュ）',
  `dtPwModified` DATETIME NULL COMMENT 'パスワード変更日時（UTC時刻）',
  `dtActivate` DATETIME NULL COMMENT 'アクティベーション日時（UTC時刻）',
  `dtLastLogin` DATETIME NULL COMMENT '最終ログイン日時（UTC時刻）',
  `nLoginFlg` TINYINT NOT NULL DEFAULT 0 COMMENT 'ログイン状態（0:未ログイン、1:ログイン状態）',
  `vcSessionID` VARCHAR(128) NULL COMMENT 'ログインセッションID',
  `nLoginFailed` TINYINT NOT NULL DEFAULT 0 COMMENT 'ログイン失敗回数カウンタ',
  `vcPIN` VARCHAR(8) NULL COMMENT '識別用PINコード',
  `dtPINModified` DATETIME NULL COMMENT 'PINコード変更日時（UTC時刻）',
  `vcFirstName` VARCHAR(32) NULL COMMENT '名',
  `vcLastName` VARCHAR(32) NULL COMMENT '姓',
  `vcTelNumber` VARCHAR(16) NULL COMMENT '連絡先電話番号',
  `vcEmail` VARCHAR(128) NULL COMMENT '連絡先E-mailアドレス',
  `vcComment` VARCHAR(256) NULL COMMENT '備考',
  `vcImageURL` VARCHAR(256) NULL COMMENT '画像ファイルURL',
  `cRoleID` CHAR(8) NOT NULL COMMENT '権限ID',
  `vcNotificationConfig` VARCHAR(16) NOT NULL DEFAULT 'NONE' COMMENT '通知設定（''ALL'' : すべて、''EMAIL_ONLY''：E-mailのみ、''SMS_ONLY''：SMSのみ、''EMAIL_SMS''：E-mailとSMS、''NONE''：通知なし）',
  `nNotificationLevel` TINYINT NOT NULL DEFAULT 0 COMMENT '通知レベル（0:未設定、10:情報、20:注意、30:警告、40:重大、50:緊急）',
  `dtCreate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時（UTC時刻）',
  `dtUpdate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新日時（UTC時刻）',
  `vcEditBy` VARCHAR(64) NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者（M_User.vcLogin）',
  PRIMARY KEY (`nUserID`))
ENGINE = InnoDB
ROW_FORMAT = COMPRESSED
COMMENT = 'ユーザーマスタ：ユーザーアカウントを管理するマスタテーブル';
