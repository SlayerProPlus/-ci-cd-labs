import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.calculator import sumar, restar, multiplicar, dividir
import pytest

def test_sumar():
    assert sumar(3, 2) == 5

def test_restar():
    assert restar(10, 4) == 6

def test_multiplicar():
    assert multiplicar(3, 4) == 12

def test_dividir():
    assert dividir(10, 2) == 5.0

def test_dividir_entre_cero():
    with pytest.raises(ValueError):
        dividir(5, 0)