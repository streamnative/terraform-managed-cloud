{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${bucket}/${path}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${bucket}/${path}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutLifecycleConfiguration",
                "s3:GetLifecycleConfiguration"
            ],
            "Resource": [
                "arn:aws:s3:::${bucket}/${path}"
            ]
        }
    ]
}