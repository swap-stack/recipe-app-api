"""
Test custom Django management commands.
"""
# Mock the behavior of the database it will simulate
# if the database gives response or not
from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):
    """Test commands"""

    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for db if database is ready"""
        # when we call or when check is called inside our comman,
        # # inside our test case we want it to return true value
        patched_check.return_value = True
        # executes the code inside the wait_for_db
        call_command('wait_for_db')
        # the mock object that is the check method inside our command
        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting OperationalError."""
        patched_check.side_effect = [Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True]
        call_command('wait_for_db')

        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])
