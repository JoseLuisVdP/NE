import bcrypt

def hash_password(password):
    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    return hashed.decode('utf-8')

def verify_password(password, hashed, method='bcrypt'):
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

if __name__ == "__main__":
    import sys
    action = sys.argv[1]
    password = sys.argv[2]
    
    if action == 'hash':
        print(hash_password(password))
    elif action == 'verify':
        hashed = sys.argv[3]
        print(verify_password(password, hashed))