> 생성일, 수정일 나중에 추가했거나 까먹었을때 쉽게 실행

### Materials

- MySQL v5.7 이상

### Methods

``` sql
ALTER TABLE {대상_테이블명} ADD COLUMN created_at datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6);

ALTER TABLE {대상_테이블명} ADD COLUMN updated_at datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6);
```
