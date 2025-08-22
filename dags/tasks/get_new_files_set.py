from typing import Dict, List, Set

from airflow.decorators import dag, task

def get_expected_patterns() -> Dict[str, str]:
    params: Dict[str, str] = {
        'sftp_dir': 'output',
        'file_pattern': 'WexDaily'
    }
    return params

def get_available_files_in_sftp(params: Dict[str, str]) -> List[str]:
    files: List[str] = ['WEXDaily-20250716-1005367298-USD.txt.gpg',
                        'AirWEXDaily-20250716-1005367298-USD.txt.gpg',
                        'WEXDaily-20250717-1005367298-USD.txt.gpg',
                        'AirWEXDaily-20250717-1005367298-USD.txt.gpg'
                        ]
    return files

def get_available_files_in_db(params: Dict[str, str]) -> List[str]:
    files: List[str] = ['WEXDaily-20250716-1005367298-USD.txt.gpg',
                        'AirWEXDaily-20250716-1005367298-USD.txt.gpg'
                        ]
    return files

@task
def get_new_files_set() -> Set[str]:
    params: Dict[str, str] = get_expected_patterns()
    return set(get_available_files_in_sftp(params)) - set(get_available_files_in_db(params))
