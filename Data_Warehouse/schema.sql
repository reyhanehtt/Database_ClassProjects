-- Data Warehouse schema (PostgreSQL)
SET DateStyle TO ISO;

CREATE OR REPLACE FUNCTION _dw_now() RETURNS timestamptz
LANGUAGE sql IMMUTABLE AS $$ SELECT now() $$;

-- =================== MEMBER ===================
CREATE TABLE IF NOT EXISTS MEMBER2(
  membership_id INT PRIMARY KEY,
  first_name    VARCHAR(15) NOT NULL,
  middle_name   VARCHAR(15),
  last_name     VARCHAR(15) NOT NULL,
  birthdate     DATE NOT NULL,
  register_date DATE NOT NULL,
  phone_number  VARCHAR(20) NOT NULL,
  address       VARCHAR(250) NOT NULL,
  insert_date   TIMESTAMPTZ NOT NULL DEFAULT _dw_now()
);
CREATE TABLE IF NOT EXISTS MEMBER_HISTORY(
  membership_id INT NOT NULL,
  first_name    VARCHAR(15) NOT NULL,
  middle_name   VARCHAR(15),
  last_name     VARCHAR(15) NOT NULL,
  birthdate     DATE NOT NULL,
  register_date DATE NOT NULL,
  phone_number  VARCHAR(20) NOT NULL,
  address       VARCHAR(250) NOT NULL,
  insert_date   TIMESTAMPTZ NOT NULL,
  delete_date   TIMESTAMPTZ NOT NULL,
  deleted       BOOLEAN NOT NULL,
  updated       BOOLEAN NOT NULL,
  PRIMARY KEY (membership_id, delete_date)
);
CREATE OR REPLACE FUNCTION dw_member_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO MEMBER2
    VALUES (NEW.membership_id, NEW.first_name, NEW.middle_name, NEW.last_name,
            NEW.birthdate, NEW.register_date, NEW.phone_number, NEW.address, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM MEMBER2 WHERE membership_id = OLD.membership_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO MEMBER_HISTORY
    VALUES (OLD.membership_id, OLD.first_name, OLD.middle_name, OLD.last_name,
            OLD.birthdate, OLD.register_date, OLD.phone_number, OLD.address,
            v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM MEMBER2 WHERE membership_id = OLD.membership_id;
    INSERT INTO MEMBER2
    VALUES (NEW.membership_id, NEW.first_name, NEW.middle_name, NEW.last_name,
            NEW.birthdate, NEW.register_date, NEW.phone_number, NEW.address, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM MEMBER2 WHERE membership_id = OLD.membership_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO MEMBER_HISTORY
    VALUES (OLD.membership_id, OLD.first_name, OLD.middle_name, OLD.last_name,
            OLD.birthdate, OLD.register_date, OLD.phone_number, OLD.address,
            v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM MEMBER2 WHERE membership_id = OLD.membership_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_member_aiud ON MEMBER;
CREATE TRIGGER dw_member_aiud
AFTER INSERT OR UPDATE OR DELETE ON MEMBER
FOR EACH ROW EXECUTE FUNCTION dw_member_aiud();

-- =================== BOOK ===================
CREATE TABLE IF NOT EXISTS BOOK2(
  ISBN           VARCHAR(13) PRIMARY KEY,
  name           VARCHAR(50) NOT NULL,
  release_date   DATE NOT NULL,
  edition_number INT NOT NULL,
  publisher      VARCHAR(50) NOT NULL,
  insert_date    TIMESTAMPTZ NOT NULL DEFAULT _dw_now()
);
CREATE TABLE IF NOT EXISTS BOOK_HISTORY(
  ISBN           VARCHAR(13) NOT NULL,
  name           VARCHAR(50) NOT NULL,
  release_date   DATE NOT NULL,
  edition_number INT NOT NULL,
  publisher      VARCHAR(50) NOT NULL,
  insert_date    TIMESTAMPTZ NOT NULL,
  delete_date    TIMESTAMPTZ NOT NULL,
  deleted        BOOLEAN NOT NULL,
  updated        BOOLEAN NOT NULL,
  PRIMARY KEY (ISBN, delete_date)
);
CREATE OR REPLACE FUNCTION dw_book_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO BOOK2 VALUES (NEW.ISBN, NEW.name, NEW.release_date, NEW.edition_number, NEW.publisher, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM BOOK2 WHERE ISBN = OLD.ISBN;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO BOOK_HISTORY VALUES (OLD.ISBN, OLD.name, OLD.release_date, OLD.edition_number, OLD.publisher,
                                     v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM BOOK2 WHERE ISBN = OLD.ISBN;
    INSERT INTO BOOK2 VALUES (NEW.ISBN, NEW.name, NEW.release_date, NEW.edition_number, NEW.publisher, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM BOOK2 WHERE ISBN = OLD.ISBN;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO BOOK_HISTORY VALUES (OLD.ISBN, OLD.name, OLD.release_date, OLD.edition_number, OLD.publisher,
                                     v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM BOOK2 WHERE ISBN = OLD.ISBN;
    RETURN OLD;
  END IF;
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_book_aiud ON BOOK;
CREATE TRIGGER dw_book_aiud
AFTER INSERT OR UPDATE OR DELETE ON BOOK
FOR EACH ROW EXECUTE FUNCTION dw_book_aiud();

-- =================== BOOK_INSTANCE ===================
CREATE TABLE IF NOT EXISTS BOOK_INSTANCE2(
  book_id    INT PRIMARY KEY,
  ISBN       VARCHAR(13) NOT NULL REFERENCES BOOK2(ISBN),
  borrowed   BOOLEAN NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL DEFAULT _dw_now()
);
CREATE TABLE IF NOT EXISTS BOOK_INSTANCE_HISTORY(
  book_id    INT NOT NULL,
  ISBN       VARCHAR(13) NOT NULL,
  borrowed   BOOLEAN NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL,
  delete_date TIMESTAMPTZ NOT NULL,
  deleted     BOOLEAN NOT NULL,
  updated     BOOLEAN NOT NULL,
  PRIMARY KEY (book_id, delete_date)
);
CREATE OR REPLACE FUNCTION dw_book_instance_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO BOOK_INSTANCE2 VALUES (NEW.book_id, NEW.ISBN, NEW.borrowed, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM BOOK_INSTANCE2 WHERE book_id = OLD.book_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO BOOK_INSTANCE_HISTORY
    VALUES (OLD.book_id, OLD.ISBN, OLD.borrowed, v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM BOOK_INSTANCE2 WHERE book_id = OLD.book_id;
    INSERT INTO BOOK_INSTANCE2 VALUES (NEW.book_id, NEW.ISBN, NEW.borrowed, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM BOOK_INSTANCE2 WHERE book_id = OLD.book_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO BOOK_INSTANCE_HISTORY
    VALUES (OLD.book_id, OLD.ISBN, OLD.borrowed, v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM BOOK_INSTANCE2 WHERE book_id = OLD.book_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_book_instance_aiud ON BOOK_INSTANCE;
CREATE TRIGGER dw_book_instance_aiud
AFTER INSERT OR UPDATE OR DELETE ON BOOK_INSTANCE
FOR EACH ROW EXECUTE FUNCTION dw_book_instance_aiud();

-- =================== WRITER ===================
CREATE TABLE IF NOT EXISTS WRITER2(
  writer_id   INT PRIMARY KEY,
  first_name  VARCHAR(15) NOT NULL,
  middle_name VARCHAR(15),
  last_name   VARCHAR(15) NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL DEFAULT _dw_now()
);
CREATE TABLE IF NOT EXISTS WRITER_HISTORY(
  writer_id   INT NOT NULL,
  first_name  VARCHAR(15) NOT NULL,
  middle_name VARCHAR(15),
  last_name   VARCHAR(15) NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL,
  delete_date TIMESTAMPTZ NOT NULL,
  deleted     BOOLEAN NOT NULL,
  updated     BOOLEAN NOT NULL,
  PRIMARY KEY (writer_id, delete_date)
);
CREATE OR REPLACE FUNCTION dw_writer_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO WRITER2 VALUES (NEW.writer_id, NEW.first_name, NEW.middle_name, NEW.last_name, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM WRITER2 WHERE writer_id = OLD.writer_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO WRITER_HISTORY
    VALUES (OLD.writer_id, OLD.first_name, OLD.middle_name, OLD.last_name,
            v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM WRITER2 WHERE writer_id = OLD.writer_id;
    INSERT INTO WRITER2 VALUES (NEW.writer_id, NEW.first_name, NEW.middle_name, NEW.last_name, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM WRITER2 WHERE writer_id = OLD.writer_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO WRITER_HISTORY
    VALUES (OLD.writer_id, OLD.first_name, OLD.middle_name, OLD.last_name,
            v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM WRITER2 WHERE writer_id = OLD.writer_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_writer_aiud ON WRITER;
CREATE TRIGGER dw_writer_aiud
AFTER INSERT OR UPDATE OR DELETE ON WRITER
FOR EACH ROW EXECUTE FUNCTION dw_writer_aiud();

-- =================== TRANSLATOR ===================
CREATE TABLE IF NOT EXISTS TRANSLATOR2(
  translator_id INT PRIMARY KEY,
  first_name  VARCHAR(15) NOT NULL,
  middle_name VARCHAR(15),
  last_name   VARCHAR(15) NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL DEFAULT _dw_now()
);
CREATE TABLE IF NOT EXISTS TRANSLATOR_HISTORY(
  translator_id INT NOT NULL,
  first_name  VARCHAR(15) NOT NULL,
  middle_name VARCHAR(15),
  last_name   VARCHAR(15) NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL,
  delete_date TIMESTAMPTZ NOT NULL,
  deleted     BOOLEAN NOT NULL,
  updated     BOOLEAN NOT NULL,
  PRIMARY KEY (translator_id, delete_date)
);
CREATE OR REPLACE FUNCTION dw_translator_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO TRANSLATOR2 VALUES (NEW.translator_id, NEW.first_name, NEW.middle_name, NEW.last_name, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM TRANSLATOR2 WHERE translator_id = OLD.translator_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO TRANSLATOR_HISTORY
    VALUES (OLD.translator_id, OLD.first_name, OLD.middle_name, OLD.last_name,
            v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM TRANSLATOR2 WHERE translator_id = OLD.translator_id;
    INSERT INTO TRANSLATOR2 VALUES (NEW.translator_id, NEW.first_name, NEW.middle_name, NEW.last_name, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM TRANSLATOR2 WHERE translator_id = OLD.translator_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO TRANSLATOR_HISTORY
    VALUES (OLD.translator_id, OLD.first_name, OLD.middle_name, OLD.last_name,
            v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM TRANSLATOR2 WHERE translator_id = OLD.translator_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_translator_aiud ON TRANSLATOR;
CREATE TRIGGER dw_translator_aiud
AFTER INSERT OR UPDATE OR DELETE ON TRANSLATOR
FOR EACH ROW EXECUTE FUNCTION dw_translator_aiud();

-- =================== LANGUAGE ===================
CREATE TABLE IF NOT EXISTS LANGUAGE2(
  name VARCHAR(15) PRIMARY KEY,
  insert_date TIMESTAMPTZ NOT NULL DEFAULT _dw_now()
);
CREATE TABLE IF NOT EXISTS LANGUAGE_HISTORY(
  name        VARCHAR(15) NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL,
  delete_date TIMESTAMPTZ NOT NULL,
  deleted     BOOLEAN NOT NULL,
  updated     BOOLEAN NOT NULL,
  PRIMARY KEY (name, delete_date)
);
CREATE OR REPLACE FUNCTION dw_language_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO LANGUAGE2 VALUES (NEW.name, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM LANGUAGE2 WHERE name = OLD.name;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO LANGUAGE_HISTORY VALUES (OLD.name, v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM LANGUAGE2 WHERE name = OLD.name;
    INSERT INTO LANGUAGE2 VALUES (NEW.name, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM LANGUAGE2 WHERE name = OLD.name;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO LANGUAGE_HISTORY VALUES (OLD.name, v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM LANGUAGE2 WHERE name = OLD.name;
    RETURN OLD;
  END IF; RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_language_aiud ON LANGUAGE;
CREATE TRIGGER dw_language_aiud
AFTER INSERT OR UPDATE OR DELETE ON LANGUAGE
FOR EACH ROW EXECUTE FUNCTION dw_language_aiud();

-- =================== GENRE ===================
CREATE TABLE IF NOT EXISTS GENRE2(
  name VARCHAR(15) PRIMARY KEY,
  insert_date TIMESTAMPTZ NOT NULL DEFAULT _dw_now()
);
CREATE TABLE IF NOT EXISTS GENRE_HISTORY(
  name        VARCHAR(15) NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL,
  delete_date TIMESTAMPTZ NOT NULL,
  deleted     BOOLEAN NOT NULL,
  updated     BOOLEAN NOT NULL,
  PRIMARY KEY (name, delete_date)
);
CREATE OR REPLACE FUNCTION dw_genre_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO GENRE2 VALUES (NEW.name, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM GENRE2 WHERE name = OLD.name;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO GENRE_HISTORY VALUES (OLD.name, v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM GENRE2 WHERE name = OLD.name;
    INSERT INTO GENRE2 VALUES (NEW.name, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM GENRE2 WHERE name = OLD.name;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO GENRE_HISTORY VALUES (OLD.name, v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM GENRE2 WHERE name = OLD.name;
    RETURN OLD;
  END IF; RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_genre_aiud ON GENRE;
CREATE TRIGGER dw_genre_aiud
AFTER INSERT OR UPDATE OR DELETE ON GENRE
FOR EACH ROW EXECUTE FUNCTION dw_genre_aiud();

-- =================== WRITES (writer-book) ===================
CREATE TABLE IF NOT EXISTS WRITES2(
  writes_id  INT PRIMARY KEY,
  writer_id  INT NOT NULL REFERENCES WRITER2(writer_id),
  ISBN       VARCHAR(13) NOT NULL REFERENCES BOOK2(ISBN),
  insert_date TIMESTAMPTZ NOT NULL DEFAULT _dw_now(),
  UNIQUE(writer_id, ISBN)
);
CREATE TABLE IF NOT EXISTS WRITES_HISTORY(
  writes_id  INT NOT NULL,
  writer_id  INT NOT NULL,
  ISBN       VARCHAR(13) NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL,
  delete_date TIMESTAMPTZ NOT NULL,
  deleted     BOOLEAN NOT NULL,
  updated     BOOLEAN NOT NULL,
  PRIMARY KEY (writes_id, delete_date)
);
CREATE OR REPLACE FUNCTION dw_writes_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO WRITES2 VALUES (NEW.writes_id, NEW.writer_id, NEW.ISBN, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM WRITES2 WHERE writes_id = OLD.writes_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO WRITES_HISTORY
    VALUES (OLD.writes_id, OLD.writer_id, OLD.ISBN, v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM WRITES2 WHERE writes_id = OLD.writes_id;
    INSERT INTO WRITES2 VALUES (NEW.writes_id, NEW.writer_id, NEW.ISBN, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM WRITES2 WHERE writes_id = OLD.writes_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO WRITES_HISTORY
    VALUES (OLD.writes_id, OLD.writer_id, OLD.ISBN, v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM WRITES2 WHERE writes_id = OLD.writes_id;
    RETURN OLD;
  END IF; RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_writes_aiud ON WRITES;
CREATE TRIGGER dw_writes_aiud
AFTER INSERT OR UPDATE OR DELETE ON WRITES
FOR EACH ROW EXECUTE FUNCTION dw_writes_aiud();

-- =================== TRANSLATES (translator-book) ===================
CREATE TABLE IF NOT EXISTS TRANSLATES2(
  translates_id INT PRIMARY KEY,
  translator_id INT NOT NULL REFERENCES TRANSLATOR2(translator_id),
  ISBN          VARCHAR(13) NOT NULL REFERENCES BOOK2(ISBN),
  insert_date   TIMESTAMPTZ NOT NULL DEFAULT _dw_now(),
  UNIQUE(translator_id, ISBN)
);
CREATE TABLE IF NOT EXISTS TRANSLATES_HISTORY(
  translates_id INT NOT NULL,
  translator_id INT NOT NULL,
  ISBN          VARCHAR(13) NOT NULL,
  insert_date   TIMESTAMPTZ NOT NULL,
  delete_date   TIMESTAMPTZ NOT NULL,
  deleted       BOOLEAN NOT NULL,
  updated       BOOLEAN NOT NULL,
  PRIMARY KEY (translates_id, delete_date)
);
CREATE OR REPLACE FUNCTION dw_translates_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO TRANSLATES2 VALUES (NEW.translates_id, NEW.translator_id, NEW.ISBN, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM TRANSLATES2 WHERE translates_id = OLD.translates_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO TRANSLATES_HISTORY
    VALUES (OLD.translates_id, OLD.translator_id, OLD.ISBN, v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM TRANSLATES2 WHERE translates_id = OLD.translates_id;
    INSERT INTO TRANSLATES2 VALUES (NEW.translates_id, NEW.translator_id, NEW.ISBN, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM TRANSLATES2 WHERE translates_id = OLD.translates_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO TRANSLATES_HISTORY
    VALUES (OLD.translates_id, OLD.translator_id, OLD.ISBN, v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM TRANSLATES2 WHERE translates_id = OLD.translates_id;
    RETURN OLD;
  END IF; RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_translates_aiud ON TRANSLATES;
CREATE TRIGGER dw_translates_aiud
AFTER INSERT OR UPDATE OR DELETE ON TRANSLATES
FOR EACH ROW EXECUTE FUNCTION dw_translates_aiud();

-- =================== IN_LANGUAGE (book-language) ===================
CREATE TABLE IF NOT EXISTS IN_LANGUAGE2(
  in_language_id INT PRIMARY KEY,
  language       VARCHAR(15) NOT NULL REFERENCES LANGUAGE2(name),
  ISBN           VARCHAR(13) NOT NULL REFERENCES BOOK2(ISBN),
  insert_date    TIMESTAMPTZ NOT NULL DEFAULT _dw_now(),
  UNIQUE(language, ISBN)
);
CREATE TABLE IF NOT EXISTS IN_LANGUAGE_HISTORY(
  in_language_id INT NOT NULL,
  language       VARCHAR(15) NOT NULL,
  ISBN           VARCHAR(13) NOT NULL,
  insert_date    TIMESTAMPTZ NOT NULL,
  delete_date    TIMESTAMPTZ NOT NULL,
  deleted        BOOLEAN NOT NULL,
  updated        BOOLEAN NOT NULL,
  PRIMARY KEY (in_language_id, delete_date)
);
CREATE OR REPLACE FUNCTION dw_in_language_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO IN_LANGUAGE2 VALUES (NEW.in_language_id, NEW.language, NEW.ISBN, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM IN_LANGUAGE2 WHERE in_language_id = OLD.in_language_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO IN_LANGUAGE_HISTORY
    VALUES (OLD.in_language_id, OLD.language, OLD.ISBN, v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM IN_LANGUAGE2 WHERE in_language_id = OLD.in_language_id;
    INSERT INTO IN_LANGUAGE2 VALUES (NEW.in_language_id, NEW.language, NEW.ISBN, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM IN_LANGUAGE2 WHERE in_language_id = OLD.in_language_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO IN_LANGUAGE_HISTORY
    VALUES (OLD.in_language_id, OLD.language, OLD.ISBN, v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM IN_LANGUAGE2 WHERE in_language_id = OLD.in_language_id;
    RETURN OLD;
  END IF; RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_in_language_aiud ON IN_LANGUAGE;
CREATE TRIGGER dw_in_language_aiud
AFTER INSERT OR UPDATE OR DELETE ON IN_LANGUAGE
FOR EACH ROW EXECUTE FUNCTION dw_in_language_aiud();

-- =================== IN_GENRE (book-genre) ===================
CREATE TABLE IF NOT EXISTS IN_GENRE2(
  in_genre_id INT PRIMARY KEY,
  genre       VARCHAR(15) NOT NULL REFERENCES GENRE2(name),
  ISBN        VARCHAR(13) NOT NULL REFERENCES BOOK2(ISBN),
  insert_date TIMESTAMPTZ NOT NULL DEFAULT _dw_now(),
  UNIQUE(genre, ISBN)
);
CREATE TABLE IF NOT EXISTS IN_GENRE_HISTORY(
  in_genre_id INT NOT NULL,
  genre       VARCHAR(15) NOT NULL,
  ISBN        VARCHAR(13) NOT NULL,
  insert_date TIMESTAMPTZ NOT NULL,
  delete_date TIMESTAMPTZ NOT NULL,
  deleted     BOOLEAN NOT NULL,
  updated     BOOLEAN NOT NULL,
  PRIMARY KEY (in_genre_id, delete_date)
);
CREATE OR REPLACE FUNCTION dw_in_genre_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO IN_GENRE2 VALUES (NEW.in_genre_id, NEW.genre, NEW.ISBN, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM IN_GENRE2 WHERE in_genre_id = OLD.in_genre_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO IN_GENRE_HISTORY
    VALUES (OLD.in_genre_id, OLD.genre, OLD.ISBN, v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM IN_GENRE2 WHERE in_genre_id = OLD.in_genre_id;
    INSERT INTO IN_GENRE2 VALUES (NEW.in_genre_id, NEW.genre, NEW.ISBN, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM IN_GENRE2 WHERE in_genre_id = OLD.in_genre_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO IN_GENRE_HISTORY
    VALUES (OLD.in_genre_id, OLD.genre, OLD.ISBN, v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM IN_GENRE2 WHERE in_genre_id = OLD.in_genre_id;
    RETURN OLD;
  END IF; RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_in_genre_aiud ON IN_GENRE;
CREATE TRIGGER dw_in_genre_aiud
AFTER INSERT OR UPDATE OR DELETE ON IN_GENRE
FOR EACH ROW EXECUTE FUNCTION dw_in_genre_aiud();

-- =================== BORROWS ===================
CREATE TABLE IF NOT EXISTS BORROWS2(
  borrow_id     INT PRIMARY KEY,
  membership_id INT NOT NULL REFERENCES MEMBER2(membership_id),
  book_id       INT NOT NULL REFERENCES BOOK_INSTANCE2(book_id),
  start_date    DATE NOT NULL,
  deadline      DATE NOT NULL,
  insert_date   TIMESTAMPTZ NOT NULL DEFAULT _dw_now()
);
CREATE TABLE IF NOT EXISTS BORROWS_HISTORY(
  borrow_id     INT NOT NULL,
  membership_id INT NOT NULL,
  book_id       INT NOT NULL,
  start_date    DATE NOT NULL,
  deadline      DATE NOT NULL,
  insert_date   TIMESTAMPTZ NOT NULL,
  delete_date   TIMESTAMPTZ NOT NULL,
  deleted       BOOLEAN NOT NULL,
  updated       BOOLEAN NOT NULL,
  PRIMARY KEY (borrow_id, delete_date)
);
CREATE OR REPLACE FUNCTION dw_borrows_aiud() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_inserted_at timestamptz;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO BORROWS2 VALUES (NEW.borrow_id, NEW.membership_id, NEW.book_id, NEW.start_date, NEW.deadline, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    SELECT insert_date INTO v_inserted_at FROM BORROWS2 WHERE borrow_id = OLD.borrow_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO BORROWS_HISTORY
    VALUES (OLD.borrow_id, OLD.membership_id, OLD.book_id, OLD.start_date, OLD.deadline,
            v_inserted_at, _dw_now(), FALSE, TRUE);
    DELETE FROM BORROWS2 WHERE borrow_id = OLD.borrow_id;
    INSERT INTO BORROWS2 VALUES (NEW.borrow_id, NEW.membership_id, NEW.book_id, NEW.start_date, NEW.deadline, DEFAULT);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    SELECT insert_date INTO v_inserted_at FROM BORROWS2 WHERE borrow_id = OLD.borrow_id;
    IF v_inserted_at IS NULL THEN v_inserted_at := _dw_now(); END IF;
    INSERT INTO BORROWS_HISTORY
    VALUES (OLD.borrow_id, OLD.membership_id, OLD.book_id, OLD.start_date, OLD.deadline,
            v_inserted_at, _dw_now(), TRUE, FALSE);
    DELETE FROM BORROWS2 WHERE borrow_id = OLD.borrow_id;
    RETURN OLD;
  END IF; RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS dw_borrows_aiud ON BORROWS;
CREATE TRIGGER dw_borrows_aiud
AFTER INSERT OR UPDATE OR DELETE ON BORROWS
FOR EACH ROW EXECUTE FUNCTION dw_borrows_aiud();
