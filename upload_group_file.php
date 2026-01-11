<?php
include 'config.php';

$group_id = $_POST['group_id'] ?? '';
$filename = $_POST['filename'] ?? '';
$filepath = $_POST['filepath'] ?? ''; // In a real app, handle file upload. Here we store URL/Path.

if (empty($group_id) || empty($filename) || empty($filepath)) {
    echo json_encode(['success' => false, 'message' => 'Missing data']);
    exit;
}

$sql = "INSERT INTO `group_files` (group_id, filename, filepath) VALUES ('$group_id', '$filename', '$filepath')";

if (mysqli_query($conn, $sql)) {
    echo json_encode(['success' => true, 'message' => 'File added']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error: ' . mysqli_error($conn)]);
}
?>
