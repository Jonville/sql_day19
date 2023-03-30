
                            ---- CURSOR ----

                            ---묵시적 커서---

---SQL%ROWCOUNT : SQP 실행 후 영향받은 행의 수
---SQL%FOUND : SQL 실행 후 영향받은 행이 있을 경우 TRUE 리턴
---SQL%NOTFOUND : SQL 실행 후 영향받은 행이 없을 경우 TRUE 리턴

-- T_USER 에서
-- 아이디를 매개변수로 보내서 검색결과가 있으면 포인트 10%증가

CREATE OR REPLACE PROCEDURE CURSOR_TEST2
    (P_ID IN T_USER.ID%TYPE)
IS
    V_POINT T_USER.POINT%TYPE;
    V_CNT NUMBER;
BEGIN
    SELECT POINT
    INTO V_POINT
    FROM T_USER
    WHERE ID = P_ID;
    
    IF SQL%FOUND THEN       -- 검색한 데이터가 존재하면 TRUE
        DBMS_OUTPUT.PUT_LINE('+----- 검색한 데이터의 포인트 : ' || V_POINT || ' -----+');
    END IF;
    
    UPDATE T_USER 
    SET POINT = POINT * 1.1     -- 10% 증가
    WHERE ID = P_ID;
    
    V_CNT := SQL%ROWCOUNT;        -- 업데이트된 행의 수
        DBMS_OUTPUT.PUT_LINE('+----- 포인트 증가 인원 수 : ' || V_CNT || ' -----+');
       
    EXCEPTION           -- 예외처리    
    WHEN NO_DATA_FOUND THEN     -- NO DATE FOUNND 가 나오면 밑에 출력 (IF 같은거)
        DBMS_OUTPUT.PUT_LINE('+----- 데이터 없음 -----+');

END;
/

EXEC CURSOR_TEST2('test123');

--------------------------------------------------------------------------------

                            ---- 명시적 커서 ----
    
    -- 특정 임시 메모리 공간안에 저장해 둔다는 의미         
    -- 임시로!
    
    -- 1. 커서 선언 -> CURSOR 커서명
        -- CURSOR 커서명 IS SELECT 속성 FROM 테이블
    -- 2. 커서 열기 -> OPEN 커서명
        -- OPEN 커서명
    -- 3. 데이터 추출 -> FETCH 커서명
        -- FETCH 커서명 INTO 변수
    -- 4. 커서 종료 -> CLOSE 커서명
        -- CLOSE 커서명

--------------------------------------------------------------------------------

                            ---- 문제풀이1 ----
                            
    -- 30번 부서에 근무하고 있는 사람의 이름과 부서 번호 출력
    
DECLARE
    V_ENAME EMP.ENAME%TYPE;
    V_DEPTNO EMP.DEPTNO%TYPE;
    
    CURSOR TEST_CUR IS      -- 검색결과가 TEST_CUR 에 담겨진다
        SELECT ENAME, DEPTNO
        FROM EMP
        WHERE DEPTNO = 30;
BEGIN
    OPEN TEST_CUR;
    LOOP
        FETCH TEST_CUR INTO V_ENAME , V_DEPTNO;
    EXIT WHEN TEST_CUR%NOTFOUND;        -- TEST_CUR = SQL 커서명
                                        
        DBMS_OUTPUT.PUT_LINE('이름 : ' || V_ENAME);
        DBMS_OUTPUT.PUT_LINE('부서번호 : ' || V_DEPTNO);
        DBMS_OUTPUT.PUT_LINE('======================');
    END LOOP;
    
    CLOSE TEST_CUR;
END;
/

--------------------------------------------------------------------------------

                            ---- 문제풀이2 ----

    -- STUDENT 테이블
    -- EXECUTE 프로시저명 ('컴퓨터정보');     -- 매개변수 학과
    -- 해당 학과 학생들의 학번, 이름, 평균점수 출력

CREATE OR REPLACE PROCEDURE STU_TEST13
    (P_DEPT IN STUDENT.STU_DEPT%TYPE)           
IS
    V_NO STUDENT.STU_NO%TYPE;
    V_NAME STUDENT.STU_NAME%TYPE;
    V_GRADE STUDENT.STU_GRADE%TYPE;

    CURSOR C_TEST IS
        SELECT S.STU_NO, STU_NAME, AVG(ENR_GRADE) AS GRADE
        FROM STUDENT S
        INNER JOIN ENROL E ON S.STU_NO = E.STU_NO
        WHERE STU_DEPT = '컴퓨터정보'
        GROUP BY S.STU_NO, STU_NAME;
BEGIN
    OPEN C_TEST;
    LOOP
        FETCH C_TEST INTO V_NO , V_NAME, V_GRADE;
    EXIT WHEN C_TEST%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('학번 : ' || V_NO);
        DBMS_OUTPUT.PUT_LINE('이름 : ' || V_NAME);
        DBMS_OUTPUT.PUT_LINE('평균 점수 : ' || V_GRADE);
        DBMS_OUTPUT.PUT_LINE('==========================');
    END LOOP;
    
    CLOSE C_TEST;
END;
/

EXECUTE STU_TEST13 ('컴퓨터정보');

--------------------------------------------------------------------------------

                            ---- 문제풀이3 ----
                            
    -- 기준 테이블 : ORDER_TABLE
    -- EXECUTE 프로시저명 ('test123');       -- 매개변수 아이디
    -- 해당아디를 가진 사람의 닉네임, 구매제품 이름, 배송상태 (배송중, 배송완료 등.....T_CODE 조인)
 
CREATE OR REPLACE PROCEDURE ORDER_TEST1
    (PRO_ID IN ORDER_TABLE.ID%TYPE)
    
IS

    V_NICKNAME T_USER.NICKNAME%TYPE;
    V_PNAME PRODUCT.P_NAME%TYPE;
    V_STATUS ORDER_TABLE.STATUS%TYPE;

    CURSOR TEST_CURSOR IS
        SELECT U.NICKNAME , P.P_NAME , C.NAME
            FROM ORDER_TABLE O
            INNER JOIN T_USER U ON U.ID = O.ID
            INNER JOIN PRODUCT P ON P.P_ID = O.P_ID
            INNER JOIN T_CODE C ON C.CODE = O.STATUS AND C.KIND = 'STATUS'
            WHERE O.ID = PRO_ID
            ;
BEGIN
    OPEN TEST_CURSOR;
    LOOP
        FETCH TEST_CURSOR INTO V_NICKNAME , V_PNAME, V_STATUS;
    EXIT WHEN TEST_CURSOR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('닉네임 : ' || V_NICKNAME);
        DBMS_OUTPUT.PUT_LINE('구매제품 이름 : ' || V_PNAME);
        DBMS_OUTPUT.PUT_LINE('배송상태 : ' || V_STATUS);
        DBMS_OUTPUT.PUT_LINE('==========================');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('전체 데이터 수 : ' || TEST_CURSOR%ROWCOUNT);
    CLOSE TEST_CURSOR;
END;
/    

EXECUTE ORDER_TEST1('test123');

                            ---- FOR ~ LOOP 문으로 ----
                
    -- 주의!     -- 출력만 되지 따로 저장을 시키진 않는다.
                            
CREATE OR REPLACE PROCEDURE ORDER_TEST1
    (PRO_ID IN ORDER_TABLE.ID%TYPE)
    
IS
    CURSOR TEST_CURSOR IS
        SELECT U.NICKNAME , P.P_NAME , C.NAME
            FROM ORDER_TABLE O
            INNER JOIN T_USER U ON U.ID = O.ID
            INNER JOIN PRODUCT P ON P.P_ID = O.P_ID
            INNER JOIN T_CODE C ON C.CODE = O.STATUS AND C.KIND = 'STATUS'
            WHERE O.ID = PRO_ID
            ;
BEGIN        
    FOR P_LIST IN TEST_CURSOR LOOP
        DBMS_OUTPUT.PUT_LINE('닉네임 : ' || P_LIST.NICKNAME);
        DBMS_OUTPUT.PUT_LINE('구매제품 이름 : ' || P_LIST.P_NAME);
        DBMS_OUTPUT.PUT_LINE('배송상태 : ' || P_LIST.NAME);
        DBMS_OUTPUT.PUT_LINE('==========================');
    END LOOP;
END;
/

EXECUTE ORDER_TEST1('test123');

--------------------------------------------------------------------------------

                            ---- 문제풀이4 ----

    -- 기준 테이블 : EMP
    -- EXECUTE 프로시저명 ('10') -- 부서번호
    -- 해당 부서번호 사람들의 사번, 이름, 급여 출력
                      
CREATE OR REPLACE PROCEDURE EMP_TEST1
    (P_DEPTNO IN EMP.DEPTNO%TYPE)
    
IS
    CURSOR TEST_CURSOR IS
        SELECT EMPNO , ENAME , SAL
        FROM EMP 
        WHERE DEPTNO = P_DEPTNO
        FOR UPDATE      -- 검색결과를 업데이트 시켜준다는 의미
        ;
BEGIN        
    FOR P_LIST IN TEST_CURSOR LOOP
        UPDATE EMP
        SET SAL = SAL + 10
        WHERE CURRENT OF TEST_CURSOR;       -- 현재 내 커서의 위치에 있는 값에 ~ 하겠다 의미
            DBMS_OUTPUT.PUT_LINE('사번 : ' || P_LIST.EMPNO);
            DBMS_OUTPUT.PUT_LINE('이름 : ' || P_LIST.ENAME);
            DBMS_OUTPUT.PUT_LINE('급여 : ' || P_LIST.SAL);
            DBMS_OUTPUT.PUT_LINE('==========================');
    END LOOP;
    
END;
/

EXECUTE EMP_TEST1('10');
