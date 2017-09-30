-- -----------------------------------------------------
-- Type      : Table
-- database  : manager
-- name      : M_User
-- version   : 0.1 @2017/09/26
-- -----------------------------------------------------
DROP TABLE IF EXISTS `manager`.`M_User` ;

CREATE TABLE IF NOT EXISTS `manager`.`M_User` (
  `nUserID` MEDIUMINT NOT NULL AUTO_INCREMENT COMMENT 'ユーザーID',
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
  `vcName` VARCHAR(64) NULL COMMENT '名名前',
  `vcTelNumber` VARCHAR(16) NULL COMMENT '連絡先電話番号',
  `vcEmail` VARCHAR(128) NULL COMMENT '連絡先E-mailアドレス',
  `vcComment` VARCHAR(256) NULL COMMENT '備考',
  `vcImageURL` VARCHAR(256) NULL COMMENT '画像ファイルURL',
  `cRoleID` CHAR(8) NOT NULL COMMENT '権限ID',
  `dtCreate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時（UTC時刻）',
  `dtUpdate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新日時（UTC時刻）',
  `vcEditBy` VARCHAR(64) NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者（M_User.vcLogin）',
  PRIMARY KEY (`nUserID`))
ENGINE = InnoDB
ROW_FORMAT = COMPRESSED
COMMENT = 'ユーザーマスタ：ユーザーアカウントを管理するマスタテーブル';


-- -----------------------------------------------------
-- Type      : Table
-- database  : manager
-- name      : M_Role
-- version   : 0.1 @2017/09/29
-- -----------------------------------------------------
DROP TABLE IF EXISTS `manager`.`M_Role` ;

CREATE TABLE IF NOT EXISTS `manager`.`M_Role` (
  `cRoleID` CHAR(8) NOT NULL COMMENT '権限ID',
  `vcKeyName` VARCHAR(64) NULL COMMENT '権限キー名',
  `vcComment` VARCHAR(256) NULL COMMENT '備考',
  `dtCreate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時（UTC時刻）',
  `dtUpdate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新日時（UTC時刻）',
  `vcEditBy` VARCHAR(64) NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者（M_User.vcLogin）',
  PRIMARY KEY (`cRoleID`))
ENGINE = InnoDB
ROW_FORMAT = COMPRESSED
COMMENT = '権限マスタ：権限を管理するマスタテーブル';


-- -----------------------------------------------------
-- Type      : View
-- database  : manager
-- name      : V_User
-- version   : 0.1 @2017/09/29
-- -----------------------------------------------------

use `manager` ;

CREATE OR REPLACE VIEW `manager`.`V_User` AS
	SELECT
		MU.nUserID				AS	nUserID,
		MU.vcLogin				AS	vcLogin,
		MU.vcPassword			AS	vcPassword,
		MU.dtPwModified			AS	dtPwModified,
		MU.dtActivate			AS	dtActivate,
		MU.dtLastLogin			AS	dtLastLogin,
		MU.nLoginFlg			AS	nLoginFlg,
		MU.vcSessionID			AS	vcSessionID,
		MU.nLoginFailed			AS	nLoginFailed,
		MU.vcPIN				AS	vcPIN,
		MU.dtPINModified		AS	dtPINModified,
		MU.vcName				AS	vcName,
		MU.vcTelNumber			AS	vcTelNumber,
		MU.vcEmail				AS	vcEmail,
		MU.vcComment			AS	vcComment,
		MU.vcImageURL			AS	vcImageURL,
		MU.cRoleID				AS	cRoleID,
		MR.vcKeyName			AS	vcRoleKeyName,
		MU.dtUpdate				AS	dtUpdate,
		MU.vcEditBy				AS	vcEditBy
	FROM
		M_User MU
	INNER JOIN M_Role MR ON
		MR.cRoleID = MU.cRoleID
;


-- -----------------------------------------------------
-- Type      : stored procedure
-- database  : manager
-- name      : SP_MOD_InsertUserHistory
-- version   : 0.1 @2017/09/29
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS `manager`.`SP_MOD_InsertUserHistory` ;

DELIMITER //

CREATE PROCEDURE `manager`.`SP_MOD_InsertUserHistory` (
				IN	inUserID	MEDIUMINT,
				IN	inOpType	CHAR(3),
				IN	inEditBy	VARCHAR(64),
				OUT	outCode		INT,			--	INTで統一
				OUT	outMsg		VARCHAR(256)
				)
	BEGIN
		--	ローカル変数宣言
		DECLARE _sqlState		CHAR(5);
		DECLARE	_errMsg			VARCHAR(256);

		--	警告をハンドル、例外時はCONTINUE
		DECLARE CONTINUE HANDLER FOR SQLWARNING SET outMsg = '[SP_MOD_InsertUserHistory] Warning.' ;
		--	エラーをハンドル、例外時はEXIT
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				GET DIAGNOSTICS CONDITION 1 _sqlState = RETURNED_SQLSTATE, _errMsg = MESSAGE_TEXT;
				SET outCode = -9;
				SET outMsg	= CONCAT('[SP_MOD_InsertUserHistory] DB error. SQLSTATE: ', IFNULL(_sqlState, ''), '. ', IFNULL(_errMsg, ''));
				--	ROLLBACK;
			END;

		--	変数初期化
		SET outCode		= 0;

		--	必須チェック
		IF	inOpType IS NULL OR inEditBy IS NULL OR
				CHAR_LENGTH(inOpType) = 0 OR CHAR_LENGTH(TRIM(inEditBy)) = 0 THEN
			SET outCode = -1;
			SET outMsg	= '[SP_MOD_InsertUserHistory] Required parameter. inOpType and inEditBy';
		--	形式チェック
		ELSEIF	CHAR_LENGTH(inOpType) <> 3 OR inOpType NOT IN ('ins', 'upd', 'del') THEN
			SET outCode	= -2;
			SET outMsg	= CONCAT('[SP_MOD_InsertUserHistory] Incorrect format. inOpType = ', inOpType);
		--	存在チェック
		END IF;

		--	処理本体
		--	START TRANSACTION;	単体処理なので、TRANSACTIONは外部の呼び出し元ROUTINEに委ねる
		IF	outCode >= 0 THEN
			IF	inUserID IS NOT NULL THEN
				INSERT INTO history.H_User (
						--	履歴ヘッダー
						dtHistory,
						cOpType,
						vcOperator,
						--	内容
						nUserID,
						vcLogin,
						vcPassword,
						dtPwModified,
						dtActivate,
						nLoginFlg,
						vcSessionID,
						dtLastLogin,
						nLoginFailed,
						vcPIN,
						dtPINModified,
						vcName,
						vcTelNumber,
						vcEmail,
						vcComment,
						vcImageURL,
						cRoleID,
						dtCreate,
						dtUpdate,
						vcEditBy
						)
					SELECT
						--	履歴ヘッダー
						CURRENT_TIMESTAMP	AS dtHistory,
						inOpType			AS cOpType,
						inEditBy			AS vcOperator,
						--	内容
						nUserID,
						vcLogin,
						vcPassword,
						dtPwModified,
						dtActivate,
						nLoginFlg,
						vcSessionID,
						dtLastLogin,
						nLoginFailed,
						vcPIN,
						dtPINModified,
						vcName,
						vcTelNumber,
						vcEmail,
						vcComment,
						vcImageURL,
						cRoleID,
						dtCreate,
						dtUpdate,
						vcEditBy
					FROM M_User
					WHERE nUserID = inUserID ;

				IF	ROW_COUNT() = 0 THEN
					SET outCode	= -3;
					SET outMsg	= CONCAT('[SP_MOD_InsertUserHistory] Inconsistent value. inUserID = ', inUserID);
				ELSE
					SET outCode	= ROW_COUNT();
				END IF;
			END IF;
		END IF;

	END;
//

DELIMITER ;

-- -----------------------------------------------------
-- Type      : stored procedure
-- database  : manager
-- name      : SP_MOD_UpsertUser
-- version   : 0.1 @2017/09/29
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS `manager`.`SP_MOD_UpsertUser` ;

DELIMITER //

CREATE PROCEDURE `manager`.`SP_MOD_UpsertUser` (
				IN	inUserID	MEDIUMINT,
				IN	inLogin		VARCHAR(64),
				IN	inPassword	VARCHAR(64),
				IN	inName		VARCHAR(64),
				IN	inTelNumber	VARCHAR(16),
				IN	inEmail		VARCHAR(128),
				IN	inComment	VARCHAR(256),
				IN	inImageURL	VARCHAR(256),
				IN	inRoleID	CHAR(8),
				IN	inEditBy	VARCHAR(64),
				OUT	outCode		INT,			--	INTで統一
				OUT	outMsg		VARCHAR(256)
				)
	BEGIN
		--	ローカル変数宣言
		DECLARE _cOpType		CHAR(3);
		DECLARE _sqlState		CHAR(5);
		DECLARE	_errMsg			VARCHAR(256);

		--	警告をハンドル、例外時はCONTINUE
		DECLARE CONTINUE HANDLER FOR SQLWARNING SET outMsg = '[SP_MOD_UpsertUser] Warning.' ;
		--	エラーをハンドル、例外時はEXIT
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				GET DIAGNOSTICS CONDITION 1 _sqlState = RETURNED_SQLSTATE, _errMsg = MESSAGE_TEXT;
				SET outCode = -9;
				SET outMsg	= CONCAT('[SP_MOD_UpsertUser] DB error. SQLSTATE: ', IFNULL(_sqlState, ''), '. ', IFNULL(_errMsg, ''));
				--	ROLLBACK;
			END;

		--	変数初期化
		SET outCode		= 0;
		SET _cOpType	= NULL;

		--	必須チェック
		IF	inLogin IS NULL OR inRoleID IS NULL OR inEditBy IS NULL OR
				CHAR_LENGTH(TRIM(inLogin)) = 0 OR CHAR_LENGTH(TRIM(inRoleID)) = 0 OR CHAR_LENGTH(TRIM(inEditBy)) = 0 THEN
			SET outCode = -1;
			SET outMsg	= '[SP_MOD_UpsertUser] Required parameter. inLogin, inRoleID and inEditBy';
		--	形式チェック
		--	存在チェック
		ELSEIF	NOT EXISTS ( SELECT cRoleID FROM M_Role WHERE cRoleID = inRoleID ) THEN
			SET outCode	= -3;
			SET outMsg	= CONCAT('[SP_MOD_UpsertUser] Inconsistent value. inRoleID = ', inRoleID);
		--	重複チェック
		ELSEIF	EXISTS ( SELECT nUserID FROM M_User
							WHERE vcLogin = TRIM(inLogin) AND
								nUserID <> IFNULL(inUserID, 0)
						) THEN
			SET outCode	= -4;
			SET outMsg	= CONCAT('[SP_MOD_UpsertUser] Duplicated value. inLogin = ', inLogin);
		END IF;

		--	処理本体
		IF	outCode >= 0 THEN
		--	START TRANSACTION;	モジュールとして、TRANSACTIONは外部の呼び出し元ROUTINEに委ねる
			IF	inUserID IS NULL THEN
				--	登録
				INSERT INTO M_User (
					vcLogin,
					vcPassword,
					dtPwModified,
					vcPIN,
					dtPINModified,
					vcName,
					vcTelNumber,
					vcEmail,
					vcComment,
					vcImageURL,
					cRoleID,
					vcEditBy
					)
				VALUES (
					TRIM(inLogin),
					MD5(inPassword),
					CASE WHEN inPassword IS NULL THEN NULL ELSE CURRENT_TIMESTAMP END,
					RIGHT(CONCAT('00000000', FLOOR(RAND() * 100000000) ), 8),
					CURRENT_TIMESTAMP,
					TRIM(inName),
					inTelNumber,
					inEmail,
					TRIM(inComment),
					TRIM(inImageURL),
					inRoleID,
					inEditBy
				);
				--	挿入ID値取得
				IF	LAST_INSERT_ID() = 0 THEN
					SET outCode	= -5;
					SET outMsg	= '[SP_MOD_UpsertUser] No data affected. Insert failed.';
				ELSE
					SET outCode		= LAST_INSERT_ID();
					SET _cOpType	= 'ins';
				END IF;
			ELSE
				--	更新
				UPDATE M_User SET
					--	パスワード変更トラップを vcPassword の設定前に
					dtPwModified	=	CASE WHEN IFNULL(vcPassword, 'N/A') <> IFNULL(MD5(inPassword), 'N/A') THEN CURRENT_TIMESTAMP ELSE dtPwModified END,
					vcLogin			=	TRIM(inLogin),	
					vcPassword		=	MD5(inPassword),
					--	PINは固定
					--	vcPIN			=	RIGHT(CONCAT('00000000', FLOOR(RAND() * 100000000) ), 8),
					vcName			=	TRIM(inName),
					vcTelNumber		=	inTelNumber,
					vcEmail			=	inEmail,
					vcComment		=	TRIM(inComment),
					vcImageURL		=	TRIM(inImageURL),
					cRoleID			=	inRoleID,
					dtUpdate		=	CURRENT_TIMESTAMP,
					vcEditBy		=	inEditBy
				WHERE
					nUserID			=	inUserID ;
				--	更新カウント取得
				IF	ROW_COUNT() = 0 THEN
					SET outCode	= -5;
					SET outMsg	= CONCAT('[SP_MOD_UpsertUser] No data affected. inUserID = ', inUserID);
				ELSE
					SET outCode		= inUserID;
					SET _cOpType	= 'upd';
				END IF;

			END IF;

			IF	outCode > 0 THEN
				--	履歴投入
				CALL	SP_MOD_InsertUserHistory(outCode, _cOpType, inEditBy, @hisOutCode, @hisOutMsg);
				IF	@hisOutCode < 0 THEN
					SET outCode	= -8;
					SET outMsg	= CONCAT('[SP_MOD_UpsertUser] History update error. ', @hisOutMsg);
				END IF;
			END IF;

		END IF;

	END;
//

DELIMITER ;

-- -----------------------------------------------------
-- Type      : stored procedure
-- database  : manager
-- name      : SP_UpsertUser
-- version   : 0.1 @2017/09/29
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS `manager`.`SP_UpsertUser` ;

DELIMITER //

CREATE PROCEDURE `manager`.`SP_UpsertUser` (
				IN	inUserID	MEDIUMINT,
				IN	inLogin		VARCHAR(64),
				IN	inPassword	VARCHAR(64),
				IN	inName		VARCHAR(64),
				IN	inTelNumber	VARCHAR(16),
				IN	inEmail		VARCHAR(128),
				IN	inComment	VARCHAR(256),
				IN	inImageURL	VARCHAR(256),
				IN	inRoleID	CHAR(8),
				IN	inEditBy	VARCHAR(64),
				OUT	outCode		INT,			--	INTで統一
				OUT	outMsg		VARCHAR(256)
				)
	BEGIN
		--	ローカル変数宣言
--		DECLARE _cOpType		CHAR(3);
		DECLARE _sqlState		CHAR(5);
		DECLARE	_errMsg			VARCHAR(256);

		--	警告をハンドル、例外時はCONTINUE
		DECLARE CONTINUE HANDLER FOR SQLWARNING SET outMsg = '[SP_UpsertUser] Warning.' ;
		--	エラーをハンドル、例外時はEXIT
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				GET DIAGNOSTICS CONDITION 1 _sqlState = RETURNED_SQLSTATE, _errMsg = MESSAGE_TEXT;
				SET outCode = -9;
				SET outMsg	= CONCAT('[SP_UpsertUser] DB error. SQLSTATE: ', IFNULL(_sqlState, ''), '. ', IFNULL(_errMsg, ''));
				ROLLBACK;
			END;

		--	変数初期化
		SET outCode		= 0;

		--	必須チェック
		--	形式チェック
		--	存在チェック
		--	重複チェック

		--	処理本体
		IF	outCode >= 0 THEN
			START TRANSACTION;
			--	処理モジュールへ
			CALL	SP_MOD_UpsertUser(
										inUserID,
										inLogin,
										inPassword,
										inName,
										inTelNumber,
										inEmail,
										inComment,
										inImageURL,
										inRoleID,
										inEditBy,
										@modOutCode, @modOutMsg
									) ;
				SET outCode	= @modOutCode;
				SET outMsg	= @modOutMsg;

			--	トランザクション処理（0は含まない）
			IF	outCode > 0 THEN
				COMMIT;
			ELSE
				ROLLBACK;
			END IF;

		END IF;

	END;
//

DELIMITER ;


-- -----------------------------------------------------
-- Type      : stored procedure
-- database  : manager
-- name      : SP_MOD_DeleteUser
-- version   : 0.1 @2017/09/30
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS `manager`.`SP_MOD_DeleteUser` ;

DELIMITER //

CREATE PROCEDURE `manager`.`SP_MOD_DeleteUser` (
				IN	inUserID			MEDIUMINT,
				IN	inEditBy			VARCHAR(64),
				OUT	outCode				INT,			--	INTで統一
				OUT	outMsg				VARCHAR(256)
				)
	BEGIN
		--	ローカル変数宣言
		DECLARE _cOpType		CHAR(3);
		DECLARE _sqlState		CHAR(5);
		DECLARE	_errMsg			VARCHAR(256);

		--	警告をハンドル、例外時はCONTINUE
		DECLARE CONTINUE HANDLER FOR SQLWARNING SET outMsg = '[SP_MOD_DeleteUser] Warning.' ;
		--	エラーをハンドル、例外時はEXIT
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				GET DIAGNOSTICS CONDITION 1 _sqlState = RETURNED_SQLSTATE, _errMsg = MESSAGE_TEXT;
				SET outCode = -9;
				SET outMsg	= CONCAT('[SP_MOD_DeleteUser] DB error. SQLSTATE: ', IFNULL(_sqlState, ''), '. ', IFNULL(_errMsg, ''));
				--	ROLLBACK;
			END;

		--	変数初期化
		SET outCode		= 0;
		SET _cOpType	= 'del';

		--	必須チェック
		IF	inEditBy IS NULL OR CHAR_LENGTH(TRIM(inEditBy)) = 0 THEN
			SET outCode = -1;
			SET outMsg	= '[SP_MOD_DeleteUser] Required parameter. inEditBy';
		--	形式チェック
		--	存在チェック
		--	重複チェック
		END IF;

		--	処理本体
		--	START TRANSACTION;	モジュールとして、TRANSACTIONは外部の呼び出し元ROUTINEに委ねる
		IF	outCode >= 0 THEN
			IF	inUserID IS NOT NULL THEN
				--	一件削除モード
				--	存在判定（やらないと存在しないときは履歴更新でエラーとなる）
				IF	NOT EXISTS ( SELECT nUserID FROM M_User WHERE nUserID = inUserID ) THEN
					SET outCode	= -3;
					SET outMsg	= CONCAT('[SP_MOD_DeleteUser] Inconsistent value. inUserID = ', inUserID, ' is not exists.');
				END IF;

				IF	outCode >= 0 THEN
					--	履歴登録（nCorpIDは無視）
					CALL	SP_MOD_InsertUserHistory(inUserID, _cOpType, inEditBy, @hisOutCode, @hisOutMsg) ;
					IF	@hisOutCode > 0 THEN
						--	一件削除（nCorpIDは無視）
						DELETE FROM M_User
						WHERE nUserID = inUserID ;

						IF	ROW_COUNT() = 0 THEN
							SET outCode	= -3;
							SET outMsg	= CONCAT('[SP_MOD_DeleteUser] Inconsistent value. inUserID = ', inUserID);
						ELSE
							SET outCode	= ROW_COUNT();
						END IF;
					ELSE
						SET outCode	= -8;
						SET outMsg	= CONCAT('[SP_MOD_DeleteUser] History update error. ', @hisOutMsg);
					END IF;

				END IF;
			END IF;
		END IF;

	END;
//

DELIMITER ;

-- -----------------------------------------------------
-- Type      : stored procedure
-- database  : manager
-- name      : SP_DeleteUser
-- version   : 0.1 @2017/09/30
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS `manager`.`SP_DeleteUser` ;

DELIMITER //

CREATE PROCEDURE `manager`.`SP_DeleteUser` (
				IN	inUserID			MEDIUMINT,
				IN	inEditBy			VARCHAR(64),
				OUT	outCode				INT,			--	INTで統一
				OUT	outMsg				VARCHAR(256)
				)
	BEGIN
		--	ローカル変数宣言
		DECLARE _sqlState		CHAR(5);
		DECLARE	_errMsg			VARCHAR(256);

		--	警告をハンドル、例外時はCONTINUE
		DECLARE CONTINUE HANDLER FOR SQLWARNING SET outMsg = '[SP_DeleteUser] Warning.' ;
		--	エラーをハンドル、例外時はEXIT
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				GET DIAGNOSTICS CONDITION 1 _sqlState = RETURNED_SQLSTATE, _errMsg = MESSAGE_TEXT;
				SET outCode = -9;
				SET outMsg	= CONCAT('[SP_DeleteUser] DB error. SQLSTATE: ', IFNULL(_sqlState, ''), '. ', IFNULL(_errMsg, ''));
				--	運用上、safe_update モードは戻しておく（このセッションだけ有効かもしれないが・・・）
				SET @@sql_safe_updates	=	1;
				ROLLBACK;
			END;

		--	変数初期化
		SET outCode		= 0;

		--	キー更新できない可能性があるので、safe_updates をOFFる。
		SET @@sql_safe_updates	=	0;

		--	必須チェック
		IF	inEditBy IS NULL OR CHAR_LENGTH(TRIM(inEditBy)) = 0 THEN
			SET outCode = -1;
			SET outMsg	= '[SP_DeleteUser] Required parameter. inEditBy';
		--	形式チェック
		--	存在チェック
		--	重複チェック
		END IF;

		--	処理本体
		IF	outCode >= 0 THEN
			START TRANSACTION;
			--	処理モジュールへ
			CALL	SP_MOD_DeleteUser(inUserID, inEditBy, @modOutCode, @modOutMsg) ;
				SET outCode	= @modOutCode;
				SET outMsg	= @modOutMsg;

			--	トランザクション処理（0は含まない）
			IF	outCode > 0 THEN
				COMMIT;
			ELSE
				ROLLBACK;
			END IF;

		END IF;

		--	運用上、safe_update モードは戻しておく（このセッションだけ有効かもしれないが・・・）
		SET @@sql_safe_updates	=	1;

	END;
//

DELIMITER ;

-- -----------------------------------------------------
-- Type      : stored procedure
-- database  : manager
-- name      : SP_ActivateUser
-- version   : 0.1 @2017/09/30
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS `manager`.`SP_ActivateUser` ;

DELIMITER //

CREATE PROCEDURE `manager`.`SP_ActivateUser` (
				IN	inUserID		INT,
				IN	inLogin			VARCHAR(64),
				IN	inPassword		VARCHAR(64),
				IN	inPIN			VARCHAR(8),
				IN	inName			VARCHAR(64),
				IN	inEditBy		VARCHAR(64),
				OUT	outCode			INT,			--	INTで統一
				OUT	outMsg			VARCHAR(256)
				)
	BEGIN
		--	ローカル変数宣言
		DECLARE _cOpType		CHAR(3);
		DECLARE _sqlState		CHAR(5);
		DECLARE	_errMsg			VARCHAR(256);

		--	警告をハンドル、例外時はCONTINUE
		DECLARE CONTINUE HANDLER FOR SQLWARNING SET outMsg = '[SP_ActivateUser] Warning.' ;
		--	エラーをハンドル、例外時はEXIT
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				GET DIAGNOSTICS CONDITION 1 _sqlState = RETURNED_SQLSTATE, _errMsg = MESSAGE_TEXT;
				SET outCode = -9;
				SET outMsg	= CONCAT('[SP_ActivateUser] DB error. SQLSTATE: ', IFNULL(_sqlState, ''), '. ', IFNULL(_errMsg, ''));
				--	ROLLBACK;
			END;

		--	変数初期化
		SET outCode		= 0;
		SET _cOpType	= 'upd';

		--	必須チェック
		IF	inUserID IS NULL OR inLogin IS NULL OR inName IS NULL OR inEditBy IS NULL OR
				CHAR_LENGTH(TRIM(inLogin)) = 0 OR CHAR_LENGTH(TRIM(inName)) = 0 OR CHAR_LENGTH(TRIM(inEditBy)) = 0 THEN
			SET outCode = -1;
			SET outMsg	= '[SP_ActivateUser] Required parameter. inUserID, inLogin, inName and inEditBy';
		--	形式チェック
		--	存在チェック
		--	重複チェック
		END IF;

		--	処理本体
		IF	outCode >= 0 THEN
			--	ユーザー情報照合
			IF	EXISTS ( SELECT nUserID FROM V_User 
										WHERE
											nUserID		=	inUserID
										AND	vcLogin		=	TRIM(inLogin)
										AND	vcName		=	TRIM(inName)
										AND IFNULL(vcPIN, 'N/A')	=	IFNULL(TRIM(inPIN), IFNULL(vcPIN, 'N/A'))
						) THEN
				--	アクティベート成功
				START TRANSACTION;
				--	情報更新
				UPDATE M_User SET
					--	パスワード変更トラップを vcPassword の設定前に
					dtPwModified	=	CASE WHEN IFNULL(vcPassword, 'N/A') <> IFNULL(MD5(inPassword), IFNULL(vcPassword, 'N/A')) THEN CURRENT_TIMESTAMP ELSE dtPwModified END,
					vcPassword		=	CASE WHEN IFNULL(vcPassword, 'N/A') <> IFNULL(MD5(inPassword), IFNULL(vcPassword, 'N/A')) THEN MD5(inPassword) ELSE vcPassword END,
					dtActivate		=	CURRENT_TIMESTAMP,
					nLoginFailed 	=	0,
					dtUpdate		=	CURRENT_TIMESTAMP,
					vcEditBy		=	inEditBy
				WHERE
					nUserID			=	inUserID ;

				--	これはケースとしては発生し得ない・・・。
				IF	ROW_COUNT() = 0 THEN
					SET outCode		= -5;
					SET outMsg		= CONCAT('[SP_ActivateUser] Activation succeeds but no data has updated. inUserID = ', inUserID, ', inLogin = ', inLogin);
				ELSE
					SET outCode		= inUserID;
				END IF;

				--	nUserID がセットされている場合のみ
				IF	outCode > 0 THEN
					--	履歴投入
					CALL	SP_MOD_InsertUserHistory(outCode, _cOpType, inEditBy, @hisOutCode, @hisOutMsg);
					IF	@hisOutCode < 0 THEN
						SET outCode	= -8;
						SET outMsg	= CONCAT('[SP_ActivateUser] History update error. ', @hisOutMsg);
					END IF;
				END IF;

				--	トランザクション処理
				IF	outCode > 0 THEN
					COMMIT;
				ELSE
					ROLLBACK;
				END IF;

			ELSE
				--	アクティベート失敗
				SET outCode	= 0;
				SET outMsg	= CONCAT('[SP_ActivateUser] Activation Failed. inUserID = ', inUserID, ', inLogin = ', inLogin);

			END IF;

		END IF;

	END;
//

DELIMITER ;

-- -----------------------------------------------------
-- Type      : stored procedure
-- database  : manager
-- name      : SP_LoginUser
-- version   : 0.1 @2017/09/30
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS `manager`.`SP_LoginUser` ;

DELIMITER //

CREATE PROCEDURE `manager`.`SP_LoginUser` (
				IN	inLogin			VARCHAR(64),
				IN	inPassword		VARCHAR(64),
				IN	inSessionID		VARCHAR(128),
				IN	inEditBy		VARCHAR(64),
				OUT	outCode			INT,			--	INTで統一
				OUT	outName			VARCHAR(64),
				OUT	outRoleID		CHAR(8),
				OUT	outRoleKeyName	VARCHAR(64),
				OUT	outLoginFailed	TINYINT,
				OUT	outOldSessionID	VARCHAR(128),
				OUT	outImageURL		VARCHAR(256),
				OUT	outMsg			VARCHAR(256)
				)
	BEGIN
		--	ローカル変数宣言
		DECLARE _cOpType		CHAR(3);
		DECLARE _sqlState		CHAR(5);
		DECLARE	_errMsg			VARCHAR(256);

		--	警告をハンドル、例外時はCONTINUE
		DECLARE CONTINUE HANDLER FOR SQLWARNING SET outMsg = '[SP_LoginUser] Warning.' ;
		--	エラーをハンドル、例外時はEXIT
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				GET DIAGNOSTICS CONDITION 1 _sqlState = RETURNED_SQLSTATE, _errMsg = MESSAGE_TEXT;
				SET outCode = -9;
				SET outMsg	= CONCAT('[SP_LoginUser] DB error. SQLSTATE: ', IFNULL(_sqlState, ''), '. ', IFNULL(_errMsg, ''));
				--	運用上、safe_updae モードは戻しておく（このセッションだけ有効かもしれないが・・・）
				SET @@sql_safe_updates	=	1;
				ROLLBACK;
			END;

		--	変数初期化
		SET outCode		= 0;
		SET _cOpType	= 'upd';

		--	キー更新できない可能性があるので、safe_updates をOFFる。
		SET @@sql_safe_updates	=	0;

		--	必須チェック
		IF	inLogin IS NULL OR inEditBy IS NULL OR
				CHAR_LENGTH(TRIM(inLogin)) = 0 OR CHAR_LENGTH(TRIM(inEditBy)) = 0 THEN
			SET outCode	= -1;
			SET outMsg	= '[SP_LoginUser] Required parameter. inLogin and inEditBy';
		--	形式チェック
		--	存在チェック
		--	重複チェック
		END IF;

		--	処理本体
		IF	outCode >= 0 THEN
			--	ログイン情報照合と out パラメータセット
			SELECT
				nUserID,
				vcName,
				cRoleID,
				vcRoleKeyName,
				nLoginFailed,
				vcSessionID,
				vcImageURL
			INTO
				outCode,
				outName,
				outRoleID,
				outRoleKeyName,
				outLoginFailed,
				outOldSessionID,
				outImageURL	
			FROM	V_User
			WHERE	vcLogin		=	inLogin
				AND	vcPassword	=	MD5(inPassword)
				AND	dtActivate	IS NOT NULL
			;

			--	SELECT ... INTO では返り値がなかった場合は何も操作されない（0が返ってきたので少なくともNULLではない）ようだ。。
			IF	IFNULL(outCode, 0) = 0 THEN
				--	ログイン失敗
				SET outCode	= 0;
				SET outMsg	= CONCAT('[SP_LoginUser] Login Failed, inLogin = ', inLogin);

				--	ログイン失敗情報更新
				UPDATE M_User
					SET
--						nLoginFlg		=	0,
						nLoginFailed 	=	nLoginFailed + 1,
						dtUpdate		=	CURRENT_TIMESTAMP,
						vcEditBy		=	inEditBy
					WHERE
						vcLogin			=	inLogin
					AND	dtActivate	IS NOT NULL ;

				--	ログイン失敗時は nUserID が判別不能なため、履歴格納はできない。。
				--	上記の条件でマッチしたアカウントの nLoginFailed がカウントアップされるだけ、とする
				--	履歴操作に及ばない単一クエリのため、トランザクションは張らない

				IF ROW_COUNT() > 0 THEN
					--	更新成功時は nLoginFailed を取得
					SELECT
						nLoginFailed
					INTO
						outLoginFailed
					FROM M_User
					WHERE
						vcLogin		=	inLogin
					AND	dtActivate	IS NOT NULL ;
				END IF;

			ELSE
				--	ログイン成功
				START TRANSACTION;
				--	ログイン成功情報更新
				UPDATE M_User SET
					dtLastLogin		=	CURRENT_TIMESTAMP,
					nLoginFlg		=	1,
					vcSessionID		=	TRIM(inSessionID),
					nLoginFailed 	=	0,
					dtUpdate		=	CURRENT_TIMESTAMP,
					vcEditBy		=	inEditBy
				WHERE
					nUserID			=	outCode ;

				--	outLoginFailed をクリア
				SET	outLoginFailed	=	0;

				--	これはケースとしては発生し得ない・・・。
				IF	ROW_COUNT() = 0 THEN
					SET outMsg		= CONCAT('[SP_LoginUser] Login succeeds but no data has updated. inLogin = ', inLogin, ', nUserID = ', outCode);
					SET outCode		= -5;
				END IF;

				--	nUserID がセットされている場合のみ
				IF	outCode > 0 THEN
					--	履歴投入
					CALL	SP_MOD_InsertUserHistory(outCode, _cOpType, inEditBy, @hisOutCode, @hisOutMsg);
					IF	@hisOutCode < 0 THEN
						SET outCode	= -8;
						SET outMsg	= CONCAT('[SP_LoginUser] History update error. ', @hisOutMsg);
					END IF;
				END IF;

			END IF;

		END IF;

		--	運用上、safe_updae モードは戻しておく（このセッションだけ有効かもしれないが・・・）
		SET @@sql_safe_updates	=	1;

	END;
//

DELIMITER ;

-- -----------------------------------------------------
-- Type      : stored procedure
-- database  : manager
-- name      : SP_LogoutUser
-- version   : 0.1 @2017/09/30
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS `manager`.`SP_LogoutUser` ;

DELIMITER //

CREATE PROCEDURE `manager`.`SP_LogoutUser` (
				IN	inUserID		MEDIUMINT,
				IN	inEditBy		VARCHAR(64),
				OUT	outCode			INT,			--	INTで統一
				OUT	outMsg			VARCHAR(256)
				)
	BEGIN
		--	ローカル変数宣言
		DECLARE _cOpType		CHAR(3);
		DECLARE _sqlState		CHAR(5);
		DECLARE	_errMsg			VARCHAR(256);

		--	警告をハンドル、例外時はCONTINUE
		DECLARE CONTINUE HANDLER FOR SQLWARNING SET outMsg = '[SP_LogoutUser] Warning.' ;
		--	エラーをハンドル、例外時はEXIT
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				GET DIAGNOSTICS CONDITION 1 _sqlState = RETURNED_SQLSTATE, _errMsg = MESSAGE_TEXT;
				SET outCode = -9;
				SET outMsg	= CONCAT('[SP_LogoutUser] DB error. SQLSTATE: ', IFNULL(_sqlState, ''), '. ', IFNULL(_errMsg, ''));
				ROLLBACK;
			END;

		--	変数初期化
		SET outCode		= 0;
		SET _cOpType	= 'upd';

		--	必須チェック
		IF	inUserID IS NULL OR inEditBy IS NULL OR CHAR_LENGTH(TRIM(inEditBy)) = 0 THEN
			SET outCode = -1;
			SET outMsg	= '[SP_LogoutUser] Required parameter. inUserID and inEditBy';
		--	形式チェック
		--	存在チェック
		--	重複チェック
		END IF;

		--	処理本体
		IF	outCode >= 0 THEN
			START TRANSACTION;
			--	nLoginFlg のリセット
			UPDATE M_User SET
				nLoginFlg		=	0,
				vcSessionID		=	NULL,
				dtUpdate		=	CURRENT_TIMESTAMP,
				vcEditBy		=	inEditBy
			WHERE
				nUserID			=	inUserID ;

			IF	ROW_COUNT() = 0 THEN
				SET outMsg		= CONCAT('[SP_LogoutUser] Inconsistent value. inUserID = ', inUserID);
				SET outCode		= -3;
			ELSE
				SET	outCode		= inUserID;
			END IF;

			--	成功時のみ
			IF	outCode > 0 THEN
				--	履歴投入
				CALL	SP_MOD_InsertUserHistory(outCode, _cOpType, inEditBy, @hisOutCode, @hisOutMsg);
				IF	@hisOutCode < 0 THEN
					SET outCode	= -8;
					SET outMsg	= CONCAT('[SP_LogoutUser] History update error. ', @hisOutMsg);
				END IF;
			END IF;

			--	トランザクション処理
			IF	outCode > 0 THEN
				COMMIT;
			ELSE
				ROLLBACK;
			END IF;

		END IF;

	END;
//

DELIMITER ;


/**
	ユーザ権限登録
	権限: SOOJR001, SOOJR002

**/
INSERT	IGNORE	INTO	`manager`.`M_Role`
VALUES ( 'SOOJR001', 'dbRoleValueSOOJR001', '管理権限', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'init-script@docker');
INSERT	IGNORE	INTO	`manager`.`M_Role`
VALUES ( 'SOOJR002', 'dbRoleValueSOOJR002', '一般権限', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'init-script@docker');

/**
	ユーザ登録・アクティベーション
	vcLogin: test@test.com
	vcPaasword: test123
**/
CALL SP_UpsertUser(null,'test@test.com',null,'テストユーザ','08012340001','test@test.com','テスト用ユーザ',NULL,'SOOJR001','init-script@docker',@outCode,@outMsg);
SELECT nUserID, vcPIN INTO @nUserID, @vcPIN FROM M_User WHERE vcLogin = 'test@test.com';
CALL SP_ActivateUser(@nUserID,'test@test.com','test123',@vcPIN,'テストユーザ','init-script@docker',@outCode,@outMsg);

