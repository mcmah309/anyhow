import 'dart:math';

import 'package:anyhow/anyhow.dart' as anyhow;
import 'package:anyhow/base.dart';
import 'package:test/test.dart';

/// Tests specific to the base Result, most other methods are tested with Anyhow
void main(){

  test("castOk",(){
    Result<int,String> someFunction1 () {return Err("err");}

    Result<String,String> someFunction2() {
      final result = someFunction1();
      if (result.isErr()) {
        return result.into();
      }
      return Ok("ok");
    }

    expect(someFunction2().unwrapErr(),"err");
    expect(Err(0).into<String>().unwrapErr(),0);
    expect(() => Ok(0).into<String>(),throwsA(isA<Panic>()));
    expect(Ok(0).into<num>().unwrap(),0);
    expect(Err(0).into().unwrapErr(),0);
    expect(Ok(0).into().unwrap(),0);
    expect(Ok(0).into().unwrap(),0);
  });

  test("toAnyhowResult", (){
    Result<int, String> x = Ok(1);
    expect(x.toAnyhowResult().unwrap(), 1);
    x = Err("err");
    expect(x.toAnyhowResult().unwrapErr().downcast<String>().unwrap(), "err");
    expect(identical(x,x.toAnyhowResult()), false);

    Ok<int, String> y = Ok(1);
    expect(y.toAnyhowResult().unwrap(), 1);
    Err<int, String> w = Err("err");
    expect(w.toAnyhowResult().unwrapErr().downcast<String>().unwrap(), "err");
    expect(identical(y,y.toAnyhowResult()), false);
    expect(identical(w,w.toAnyhowResult()), false);

    anyhow.Result<int> z = anyhow.Ok(1);
    expect(z.toAnyhowResult().unwrap(), 1);
    z = bail("err");
    expect(z.toAnyhowResult().unwrapErr().downcast<String>().unwrap(), "err");
    expect(identical(z,z.toAnyhowResult()), true);
  });
}