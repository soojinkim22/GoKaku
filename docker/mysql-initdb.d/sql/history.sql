-- -----------------------------------------------------
-- Type      : Table
-- database  : history
-- name      : H_User
-- version   : 0.1 @2017/09/26
-- -----------------------------------------------------

DROP TABLE IF EXISTS `history`.`H_User`;

CREATE TABLE `history`.`H_User` (
  `nHistoryID` int(11) NOT NULL AUTO_INCREMENT COMMENT '履歴ID',
  `dtHistory` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '履歴日時（UTC時刻）',
  `cOpType` char(3) NOT NULL COMMENT '操作種別（''ins'': 追加, ''upd'': 更新, ''del'': 削除）',
  `vcOperator` varchar(64) NOT NULL COMMENT '更新者（=vcEditBy）',
  `nUserID` mediumint(9) DEFAULT NULL COMMENT 'ユーザーID',
  `nCorpID` smallint(6) DEFAULT NULL COMMENT '企業ID',
  `vcLogin` varchar(64) DEFAULT NULL COMMENT 'ログイン文字列',
  `vcPassword` varchar(64) DEFAULT NULL COMMENT 'パスワード文字列（MD5ハッシュ）',
  `dtPwModified` datetime DEFAULT NULL COMMENT 'パスワード変更日時（UTC時刻）',
  `dtActivate` datetime DEFAULT NULL COMMENT 'アクティベーション日時（UTC時刻）',
  `dtLastLogin` datetime DEFAULT NULL COMMENT '最終ログイン日時（UTC時刻）',
  `nLoginFlg` tinyint(4) DEFAULT NULL COMMENT 'ログイン状態（0:未ログイン、1:ログイン状態）',
  `vcSessionID` varchar(128) DEFAULT NULL COMMENT 'ログインセッションID',
  `nLoginFailed` tinyint(4) DEFAULT NULL COMMENT 'ログイン失敗回数カウンタ',
  `vcPIN` varchar(8) DEFAULT NULL COMMENT '識別用PINコード',
  `dtPINModified` datetime DEFAULT NULL COMMENT 'PINコード変更日時（UTC時刻）',
  `vcFirstName` varchar(32) DEFAULT NULL COMMENT '名',
  `vcLastName` varchar(32) DEFAULT NULL COMMENT '姓',
  `vcTelNumber` varchar(16) DEFAULT NULL COMMENT '連絡先電話番号',
  `vcEmail` varchar(128) DEFAULT NULL COMMENT '連絡先E-mailアドレス',
  `vcComment` varchar(256) DEFAULT NULL COMMENT '備考',
  `vcImageURL` varchar(256) DEFAULT NULL COMMENT '画像ファイルURL',
  `cRoleID` char(8) DEFAULT NULL COMMENT '権限ID',
  `vcNotificationConfig` varchar(16) DEFAULT NULL COMMENT '通知設定（''ALL'' : すべて、''EMAIL_ONLY''：E-mailのみ、''SMS_ONLY''：SMSのみ、''EMAIL_SMS''：E-mailとSMS、''NONE''：通知なし）',
  `nNotificationLevel` tinyint(4) DEFAULT NULL COMMENT '通知レベル（0:未設定、10:情報、20:注意、30:警告、40:重大、50:緊急）',
  `dtCreate` datetime DEFAULT NULL COMMENT '作成日時（UTC時刻）',
  `dtUpdate` datetime DEFAULT NULL COMMENT '更新日時（UTC時刻）',
  `vcEditBy` varchar(64) DEFAULT NULL COMMENT '更新者（M_User.vcLogin）',
  PRIMARY KEY (`nHistoryID`,`dtHistory`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED COMMENT='ユーザーマスタ履歴';

