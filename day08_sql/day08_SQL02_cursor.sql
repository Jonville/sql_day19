
                            ---- CURSOR ----

                            ---������ Ŀ��---

---SQL%ROWCOUNT : SQP ���� �� ������� ���� ��
---SQL%FOUND : SQL ���� �� ������� ���� ���� ��� TRUE ����
---SQL%NOTFOUND : SQL ���� �� ������� ���� ���� ��� TRUE ����

-- T_USER ����
-- ���̵� �Ű������� ������ �˻������ ������ ����Ʈ 10%����

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
    
    IF SQL%FOUND THEN       -- �˻��� �����Ͱ� �����ϸ� TRUE
        DBMS_OUTPUT.PUT_LINE('+----- �˻��� �������� ����Ʈ : ' || V_POINT || ' -----+');
    END IF;
    
    UPDATE T_USER 
    SET POINT = POINT * 1.1     -- 10% ����
    WHERE ID = P_ID;
    
    V_CNT := SQL%ROWCOUNT;        -- ������Ʈ�� ���� ��
        DBMS_OUTPUT.PUT_LINE('+----- ����Ʈ ���� �ο� �� : ' || V_CNT || ' -----+');
       
    EXCEPTION           -- ����ó��    
    WHEN NO_DATA_FOUND THEN     -- NO DATE FOUNND �� ������ �ؿ� ��� (IF ������)
        DBMS_OUTPUT.PUT_LINE('+----- ������ ���� -----+');

END;
/

EXEC CURSOR_TEST2('test123');

--------------------------------------------------------------------------------

                            ---- ����� Ŀ�� ----
    
    -- Ư�� �ӽ� �޸� �����ȿ� ������ �дٴ� �ǹ�         
    -- �ӽ÷�!
    
    -- 1. Ŀ�� ���� -> CURSOR Ŀ����
        -- CURSOR Ŀ���� IS SELECT �Ӽ� FROM ���̺�
    -- 2. Ŀ�� ���� -> OPEN Ŀ����
        -- OPEN Ŀ����
    -- 3. ������ ���� -> FETCH Ŀ����
        -- FETCH Ŀ���� INTO ����
    -- 4. Ŀ�� ���� -> CLOSE Ŀ����
        -- CLOSE Ŀ����

--------------------------------------------------------------------------------

                            ---- ����Ǯ��1 ----
                            
    -- 30�� �μ��� �ٹ��ϰ� �ִ� ����� �̸��� �μ� ��ȣ ���
    
DECLARE
    V_ENAME EMP.ENAME%TYPE;
    V_DEPTNO EMP.DEPTNO%TYPE;
    
    CURSOR TEST_CUR IS      -- �˻������ TEST_CUR �� �������
        SELECT ENAME, DEPTNO
        FROM EMP
        WHERE DEPTNO = 30;
BEGIN
    OPEN TEST_CUR;
    LOOP
        FETCH TEST_CUR INTO V_ENAME , V_DEPTNO;
    EXIT WHEN TEST_CUR%NOTFOUND;        -- TEST_CUR = SQL Ŀ����
                                        
        DBMS_OUTPUT.PUT_LINE('�̸� : ' || V_ENAME);
        DBMS_OUTPUT.PUT_LINE('�μ���ȣ : ' || V_DEPTNO);
        DBMS_OUTPUT.PUT_LINE('======================');
    END LOOP;
    
    CLOSE TEST_CUR;
END;
/

--------------------------------------------------------------------------------

                            ---- ����Ǯ��2 ----

    -- STUDENT ���̺�
    -- EXECUTE ���ν����� ('��ǻ������');     -- �Ű����� �а�
    -- �ش� �а� �л����� �й�, �̸�, ������� ���

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
        WHERE STU_DEPT = '��ǻ������'
        GROUP BY S.STU_NO, STU_NAME;
BEGIN
    OPEN C_TEST;
    LOOP
        FETCH C_TEST INTO V_NO , V_NAME, V_GRADE;
    EXIT WHEN C_TEST%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('�й� : ' || V_NO);
        DBMS_OUTPUT.PUT_LINE('�̸� : ' || V_NAME);
        DBMS_OUTPUT.PUT_LINE('��� ���� : ' || V_GRADE);
        DBMS_OUTPUT.PUT_LINE('==========================');
    END LOOP;
    
    CLOSE C_TEST;
END;
/

EXECUTE STU_TEST13 ('��ǻ������');

--------------------------------------------------------------------------------

                            ---- ����Ǯ��3 ----
                            
    -- ���� ���̺� : ORDER_TABLE
    -- EXECUTE ���ν����� ('test123');       -- �Ű����� ���̵�
    -- �ش�Ƶ� ���� ����� �г���, ������ǰ �̸�, ��ۻ��� (�����, ��ۿϷ� ��.....T_CODE ����)
 
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
        DBMS_OUTPUT.PUT_LINE('�г��� : ' || V_NICKNAME);
        DBMS_OUTPUT.PUT_LINE('������ǰ �̸� : ' || V_PNAME);
        DBMS_OUTPUT.PUT_LINE('��ۻ��� : ' || V_STATUS);
        DBMS_OUTPUT.PUT_LINE('==========================');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('��ü ������ �� : ' || TEST_CURSOR%ROWCOUNT);
    CLOSE TEST_CURSOR;
END;
/    

EXECUTE ORDER_TEST1('test123');

                            ---- FOR ~ LOOP ������ ----
                
    -- ����!     -- ��¸� ���� ���� ������ ��Ű�� �ʴ´�.
                            
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
        DBMS_OUTPUT.PUT_LINE('�г��� : ' || P_LIST.NICKNAME);
        DBMS_OUTPUT.PUT_LINE('������ǰ �̸� : ' || P_LIST.P_NAME);
        DBMS_OUTPUT.PUT_LINE('��ۻ��� : ' || P_LIST.NAME);
        DBMS_OUTPUT.PUT_LINE('==========================');
    END LOOP;
END;
/

EXECUTE ORDER_TEST1('test123');

--------------------------------------------------------------------------------

                            ---- ����Ǯ��4 ----

    -- ���� ���̺� : EMP
    -- EXECUTE ���ν����� ('10') -- �μ���ȣ
    -- �ش� �μ���ȣ ������� ���, �̸�, �޿� ���
                      
CREATE OR REPLACE PROCEDURE EMP_TEST1
    (P_DEPTNO IN EMP.DEPTNO%TYPE)
    
IS
    CURSOR TEST_CURSOR IS
        SELECT EMPNO , ENAME , SAL
        FROM EMP 
        WHERE DEPTNO = P_DEPTNO
        FOR UPDATE      -- �˻������ ������Ʈ �����شٴ� �ǹ�
        ;
BEGIN        
    FOR P_LIST IN TEST_CURSOR LOOP
        UPDATE EMP
        SET SAL = SAL + 10
        WHERE CURRENT OF TEST_CURSOR;       -- ���� �� Ŀ���� ��ġ�� �ִ� ���� ~ �ϰڴ� �ǹ�
            DBMS_OUTPUT.PUT_LINE('��� : ' || P_LIST.EMPNO);
            DBMS_OUTPUT.PUT_LINE('�̸� : ' || P_LIST.ENAME);
            DBMS_OUTPUT.PUT_LINE('�޿� : ' || P_LIST.SAL);
            DBMS_OUTPUT.PUT_LINE('==========================');
    END LOOP;
    
END;
/

EXECUTE EMP_TEST1('10');
