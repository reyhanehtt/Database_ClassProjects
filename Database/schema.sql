CREATE TABLE MEMBER(
   first_name VARCHAR ( 15 ) NOT NULL,
   middle_name VARCHAR ( 15 ) ,
   last_name VARCHAR ( 15 ) NOT NULL,
   birthdate DATE NOT NULL,
   register_date DATE NOT NULL,
   membership_id INT UNIQUE NOT NULL,
   phone_number VARCHAR ( 20 ) NOT NULL,
   address VARCHAR ( 250 ) NOT NULL,
   PRIMARY KEY (membership_id)
);

CREATE TABLE MEMBER2(
   first_name VARCHAR ( 15 ) NOT NULL,
   middle_name VARCHAR ( 15 ) ,
   last_name VARCHAR ( 15 ) NOT NULL,
   birthdate DATE NOT NULL,
   register_date DATE NOT NULL,
   membership_id INT UNIQUE NOT NULL,
   phone_number VARCHAR ( 20 ) NOT NULL,
   address VARCHAR ( 250 ) NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY (membership_id)
);

CREATE TABLE MEMBER_HISTORY(
   first_name VARCHAR ( 15 ) NOT NULL,
   middle_name VARCHAR ( 15 ) ,
   last_name VARCHAR ( 15 ) NOT NULL,
   birthdate DATE NOT NULL,
   register_date DATE NOT NULL,
   membership_id INT UNIQUE NOT NULL,
   phone_number VARCHAR ( 20 ) NOT NULL,
   address VARCHAR ( 250 ) NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY (membership_id)
);



INSERT INTO MEMBER2(first_name, middle_name, last_name,birthdate,register_date, membership_id, phone_number,address)
SELECT * FROM MEMBER ;

CREATE TRIGGER log_update_MEMBER
    BEFORE UPDATE ON MEMBER
    FOR EACH ROW
    INSERT INTO MEMBER_HISTORY(first_name, middle_name, last_name,birthdate,register_date, membership_id, phone_number,address,insert_date,FALSE,TRUE)
    VALUES (SELECT *
    FROM MEMBER2
    WHERE MEMBER2.membership_id = MEMBER.OLD.membership_id)
    AND
    INSERT INTO MEMBER2(NEW.first_name,NEW.middle_name,NEW.last_name,NEW.birthdate,NEW.register_date,NEW.membership_id,NEW.phone_number,NEW.address,current_date)
    SELECT * FROM MEMBER
    WHERE MEMBER2.membership_id = MEMBER.OLD.membership_id AND  MEMBER2.membership_id <> MEMBER.NEW.membership_id ;

CREATE TRIGGER log_delete_MEMBER
    BEFORE DELETE ON MEMBER
    FOR EACH ROW
    INSERT INTO MEMBER_HISTORY(first_name, middle_name, last_name,birthdate,register_date, membership_id, phone_number,address,insert_date,TRUE,FALSE)
    VALUES (SELECT *
    FROM MEMBER2
    WHERE MEMBER2.membership_id = MEMBER.OLD.membership_id)
    AND
    DELETE FROM MEMBER2
    WHERE MEMBER2.membership_id = MEMBER.OLD.membership_id ;

CREATE TRIGGER log_insert_MEMBER
     AFTER INSERT ON MEMBER
     INSERT INTO MEMBER2(first_name, middle_name, last_name,birthdate,register_date, membership_id, phone_number,address)
     SELECT NEW.* ;

CREATE TABLE BOOK(
   name VARCHAR ( 50 ) NOT NULL,
   release_date DATE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   edition_number INT NOT NULL,
   publisher VARCHAR ( 50 ) NOT NULL,
   PRIMARY KEY (ISBN)
);

CREATE TABLE BOOK2(
   name VARCHAR ( 50 ) NOT NULL,
   release_date DATE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   edition_number INT NOT NULL,
   publisher VARCHAR ( 50 ) NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY (ISBN)
);

CREATE TABLE BOOK_HISTORY(
   name VARCHAR ( 50 ) NOT NULL,
   release_date DATE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   edition_number INT NOT NULL,
   publisher VARCHAR ( 50 ) NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY (ISBN)
);

INSERT INTO BOOK2(name, release_date,ISBN,edition_number,publisher)
SELECT * FROM BOOK;

CREATE TRIGGER log_update_BOOK
    BEFORE UPDATE ON BOOK
    FOR EACH ROW
    INSERT INTO BOOK_HISTORY(name, release_date,ISBN,edition_number,publisher,insert_date,FALSE,TRUE)
    VALUES (SELECT *
    FROM BOOK2
    WHERE BOOK2.ISBN = BOOK.OLD.ISBN)
    AND
    INSERT INTO BOOK2(NEW.name, NEW.release_date,NEW.ISBN,NEW.edition_number,NEW.publisher,current_date)
    SELECT * FROM BOOK
    WHERE BOOK2.ISBN = BOOK.OLD.ISBN AND  BOOK2.ISBN <> BOOK.NEW.ISBN ;

CREATE TRIGGER log_delete_BOOK
    BEFORE DELETE ON BOOK
    FOR EACH ROW
    INSERT INTO BOOK_HISTORY(name, release_date,ISBN,edition_number,publisher,insert_date,TRUE,FALSE)
    VALUES (SELECT *
    FROM BOOK2
    WHERE BOOK2.ISBN = BOOK.OLD.ISBN)
    AND
    DELETE FROM MEMBER2
    WHERE BOOK2.ISBN = BOOK.OLD.ISBN ;

CREATE TRIGGER log_insert_BOOK
     AFTER INSERT ON BOOK
     INSERT INTO BOOK2(name, release_date,ISBN,edition_number,publisher)
     SELECT NEW.* ;

/* WE BUILD THE SAME 3 TRIGGERS FOR EVERY OTHER TABLE AS WELL*/

CREATE TABLE BOOK_INSTANCE(
   book_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) NOT NULL,
   borrowed BOOLEAN NOT NULL,
   PRIMARY KEY (book_id),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE BOOK_INSTANCE2(
   book_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) NOT NULL,
   borrowed BOOLEAN NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY (book_id),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE BOOK_INSTANCE_HISTORY(
   book_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) NOT NULL,
   borrowed BOOLEAN NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY (book_id),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

INSERT INTO BOOK_INSTANCE2(book_id,ISBN,borrowed)
SELECT * FROM BOOK_INSTANCE;

CREATE TABLE WRITER(
   writer_id INT UNIQUE NOT NULL,
   first_name VARCHAR ( 15 ) NOT NULL,
   middle_name VARCHAR ( 15 ) ,
   last_name VARCHAR ( 15 ) NOT NULL,
   PRIMARY KEY (writer_id)
);

CREATE TABLE WRITER2(
   writer_id INT UNIQUE NOT NULL,
   first_name VARCHAR ( 15 ) NOT NULL,
   middle_name VARCHAR ( 15 ) ,
   last_name VARCHAR ( 15 ) NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY (writer_id)
);

CREATE TABLE WRITER_HISTORY(
   writer_id INT UNIQUE NOT NULL,
   first_name VARCHAR ( 15 ) NOT NULL,
   middle_name VARCHAR ( 15 ) ,
   last_name VARCHAR ( 15 ) NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY (writer_id)
);

INSERT INTO WRITER2(writer_id,first_name,middle_name,last_name)
SELECT * FROM WRITER;

CREATE TABLE TRANSLATOR(
   translator_id INT UNIQUE NOT NULL,
   first_name VARCHAR ( 15 ) NOT NULL,
   middle_name VARCHAR ( 15 ) ,
   last_name VARCHAR ( 15 ) NOT NULL,
   PRIMARY KEY (translator_id)
);

CREATE TABLE TRANSLATOR2(
   translator_id INT UNIQUE NOT NULL,
   first_name VARCHAR ( 15 ) NOT NULL,
   middle_name VARCHAR ( 15 ) ,
   last_name VARCHAR ( 15 ) NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY (translator_id)
);

CREATE TABLE TRANSLATOR_HISTORY(
   translator_id INT UNIQUE NOT NULL,
   first_name VARCHAR ( 15 ) NOT NULL,
   middle_name VARCHAR ( 15 ) ,
   last_name VARCHAR ( 15 ) NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY (translator_id)
);

INSERT INTO TRANSLATOR2(translator_id,first_name,middle_name,last_name)
SELECT * FROM TRANSLATOR;

CREATE TABLE LANGUAGE(
   name VARCHAR( 15 ) UNIQUE NOT NULL,
   PRIMARY KEY (name)
);

CREATE TABLE LANGUAGE2(
   name VARCHAR( 15 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY (name)
);

CREATE TABLE LANGUAGE_HISTORY(
   name VARCHAR( 15 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY (name)
);

INSERT INTO LANGUAGE2(name)
SELECT * FROM LANGUAGE;


CREATE TABLE GENRE(
   name VARCHAR( 15 ) UNIQUE NOT NULL,
   PRIMARY KEY (name)
);

CREATE TABLE GENRE2(
   name VARCHAR( 15 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY (name)
);

CREATE TABLE GENRE_HISTORY(
   name VARCHAR( 15 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY (name)
);

INSERT INTO GENRE2(name)
SELECT * FROM GENRE;

CREATE TABLE INSTANCE_OF(
   instance_of_id INT UNIQUE NOT NULL,
   book_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   PRIMARY KEY ( instance_of_id ),
   FOREIGN KEY (book_id) references BOOK_INSTANCE(book_id),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE INSTANCE_OF2(
   instance_of_id INT UNIQUE NOT NULL,
   book_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY ( instance_of_id ),
   FOREIGN KEY (book_id) references BOOK_INSTANCE(book_id),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE INSTANCE_OF_HISTORY(
   instance_of_id INT UNIQUE NOT NULL,
   book_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY ( instance_of_id ),
   FOREIGN KEY (book_id) references BOOK_INSTANCE_HISTORY(book_id),
   FOREIGN KEY (ISBN) references BOOK_HISTORY(ISBN)
);

INSERT INTO INSTANCE_OF2(instance_of_id,book_id,ISBN)
SELECT * FROM INSTANCE_OF;

CREATE TABLE BORROWS(
   borrow_id INT UNIQUE NOT NULL,
   membership_id INT UNIQUE NOT NULL,
   book_id INT UNIQUE NOT NULL,
   start_date DATE NOT NULL,
   deadline DATE NOT NULL,
   PRIMARY KEY ( borrow_id ),
   FOREIGN KEY (membership_id) references MEMBER(membership_id),
   FOREIGN KEY (book_id) references BOOK_INSTANCE(book_id)
);

CREATE TABLE BORROWS2(
   borrow_id INT UNIQUE NOT NULL,
   membership_id INT UNIQUE NOT NULL,
   book_id INT UNIQUE NOT NULL,
   start_date DATE NOT NULL,
   deadline DATE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY ( borrow_id ),
   FOREIGN KEY (membership_id) references MEMBER(membership_id),
   FOREIGN KEY (book_id) references BOOK_INSTANCE(book_id)
);

CREATE TABLE BORROWS_HISTORY(
   borrow_id INT UNIQUE NOT NULL,
   membership_id INT UNIQUE NOT NULL,
   book_id INT UNIQUE NOT NULL,
   start_date DATE NOT NULL,
   deadline DATE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY ( borrow_id ),
   FOREIGN KEY (membership_id) references MEMBER_HISTORY(membership_id),
   FOREIGN KEY (book_id) references BOOK_INSTANCE_HISTORY(book_id)
);

INSERT INTO BORROWS2(borrow_id, membership_id, book_id,start_date,deadline)
SELECT * FROM BORROWS;

CREATE TABLE WRITES(
   writes_id INT UNIQUE NOT NULL,
   writer_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   PRIMARY KEY ( writes_id ),
   FOREIGN KEY (writer_id) references WRITER(writer_id),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE WRITES2(
   writes_id INT UNIQUE NOT NULL,
   writer_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY ( writes_id ),
   FOREIGN KEY (writer_id) references WRITER(writer_id),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE WRITES_HISTORY(
   writes_id INT UNIQUE NOT NULL,
   writer_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY ( writes_id ),
   FOREIGN KEY (writer_id) references WRITER_HISTORY(writer_id),
   FOREIGN KEY (ISBN) references BOOK_HISTORY(ISBN)
);


INSERT INTO WRITES2(writes_id,writer_id,ISBN)
SELECT * FROM WRITES;

CREATE TABLE TRANSLATES(
   translates_id INT UNIQUE NOT NULL,
   translator_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   PRIMARY KEY ( translates_id ),
   FOREIGN KEY (translator_id) references TRANSLATES(translator_id),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE TRANSLATES2(
   translates_id INT UNIQUE NOT NULL,
   translator_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY ( translates_id ),
   FOREIGN KEY (translator_id) references TRANSLATES(translator_id),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE TRANSLATES_HISTORY(
   translates_id INT UNIQUE NOT NULL,
   translator_id INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY ( translates_id ),
   FOREIGN KEY (translator_id) references TRANSLATES_HISTORY(translator_id),
   FOREIGN KEY (ISBN) references BOOK_HISTORY(ISBN)
);

INSERT INTO TRANSLATES2(translates_id,translator_id,ISBN)
SELECT * FROM TRANSLATES;

CREATE TABLE IN_LANGUAGE(
   in_language_id int NOT NULL,
   language INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   PRIMARY KEY ( in_language_id ),
   FOREIGN KEY (language) references LANGUAGE(name),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE IN_LANGUAGE2(
   in_language_id int NOT NULL,
   language INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY ( in_language_id ),
   FOREIGN KEY (language) references LANGUAGE(name),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE IN_LANGUAGE_HISTORY(
   in_language_id int NOT NULL,
   language INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY ( in_language_id ),
   FOREIGN KEY (language) references LANGUAGE_HISTORY(name),
   FOREIGN KEY (ISBN) references BOOK_HISTORY(ISBN)
);

INSERT INTO IN_LANGUAGE2(in_language_id,language, ISBN)
SELECT * FROM IN_LANGUAGE;

CREATE TABLE IN_GENRE(
   in_genre_id INT UNIQUE NOT NULL,
   genre INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   PRIMARY KEY ( in_genre_id ),
   FOREIGN KEY (genre) references GENRE(name),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE IN_GENRE2(
   in_genre_id INT UNIQUE NOT NULL,
   genre INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   PRIMARY KEY ( in_genre_id ),
   FOREIGN KEY (genre) references GENRE(name),
   FOREIGN KEY (ISBN) references BOOK(ISBN)
);

CREATE TABLE IN_GENRE_HISTORY(
   in_genre_id INT UNIQUE NOT NULL,
   genre INT UNIQUE NOT NULL,
   ISBN VARCHAR( 13 ) UNIQUE NOT NULL,
   insert_date DATE NOT NULL DEFAULT current_date,
   delete_date DATE NOT NULL DEFAULT current_date,
   deleted  boolean NOT NULL,
   updated  boolean NOT NULL,
   PRIMARY KEY ( in_genre_id ),
   FOREIGN KEY (genre) references GENRE_HISTORY(name),
   FOREIGN KEY (ISBN) references BOOK_HISTORY(ISBN)
);

INSERT INTO IN_GENRE2(in_genre_id,genre,ISBN)
SELECT * FROM IN_GENRE;